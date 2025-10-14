// lib/widgets/audio_player_handler.dart

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart'; // <<< NOVO IMPORT
import '../models/radio_station.dart'; 

// --- FUNÇÃO AUXILIAR DE CRIAÇÃO DO MEDIA ITEM (Mantida) ---
MediaItem createMediaItem(RadioStation station) {
  return MediaItem(
    id: station.streamUrl, 
    album: station.name, 
    title: station.name, 
    artist: station.location, 
    artUri: Uri.parse(station.artUrl)
  );
}
// -------------------------------------------------------------

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  
  // NOVO: Stream para guardar e emitir o último erro de reprodução
  final _currentError = BehaviorSubject<String?>.seeded(null);
  Stream<String?> get currentError => _currentError.stream; // Getter público

  AudioPlayerHandler() { _init(); }
  
  Future<void> _init() async {
    _player.icyMetadataStream.listen((metadata) {
      final mediaItemAtual = mediaItem.value;
      if (mediaItemAtual == null) return;
      final title = metadata?.info?.title;
      
      if (title != null && title.isNotEmpty && title != mediaItemAtual.album) {
        final novoMediaItem = mediaItemAtual.copyWith(title: title);
        mediaItem.add(novoMediaItem);
      }
    });
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  Future<void> loadStation(RadioStation station) async {
    final mediaItem = createMediaItem(station);
    this.mediaItem.add(mediaItem);
  }
  
  // --- MÉTODO playStation ATUALIZADO com User-Agent, Erro e await play() ---
  Future<void> playStation(RadioStation station) async {
    // 1. Limpa o erro anterior antes de tentar tocar um novo
    _currentError.add(null); 
    await RadioStation.saveStation(station); 
    final mediaItem = createMediaItem(station); 
    
    try {
      // Adicionado User-Agent para melhor compatibilidade com streams restritos (BandNews, Jovem Pan)
      const userAgentString = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Safari/537.36';

      final audioSource = AudioSource.uri(
        Uri.parse(station.streamUrl),
        headers: {
          'User-Agent': userAgentString,
        },
      );

      await _player.setAudioSource(audioSource);
      
      this.mediaItem.add(mediaItem);
      await play(); // <<< AGORA FORÇA O INÍCIO DA REPRODUÇÃO

    } catch (e) {
      // 2. Captura a mensagem de erro
      final errorMessage = 'Falha ao tocar ${station.name}. Causa: ${e.toString().split(':').first}';
      
      // 3. Armazena a mensagem de erro para ser exibida na tela
      _currentError.add(errorMessage); 
      
      // 4. Para o player para limpar o estado
      stop();
    }
  }
  
  @override
  Future<void> play() => _player.play();
  
  @override
  Future<void> pause() => _player.pause();
  
  @override
  Future<void> stop() async {
    await _player.stop();
    // Limpar o mediaItem da interface quando parar
    if (mediaItem.value != null) {
      mediaItem.add(null);
    }
    await super.stop();
  }
  
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [if (_player.playing) MediaControl.pause else MediaControl.play, MediaControl.stop],
      systemActions: const {},
      androidCompactActionIndices: const [0],
      processingState: _getProcessingState(event),
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex
    );
  }
  
  AudioProcessingState _getProcessingState(PlaybackEvent event) {
    switch (event.processingState) {
      case ProcessingState.idle: return AudioProcessingState.idle;
      case ProcessingState.loading: return AudioProcessingState.loading;
      case ProcessingState.buffering: return AudioProcessingState.buffering;
      case ProcessingState.ready: return AudioProcessingState.ready;
      case ProcessingState.completed: return AudioProcessingState.completed;
      default: return AudioProcessingState.error;
    }
  }
}
