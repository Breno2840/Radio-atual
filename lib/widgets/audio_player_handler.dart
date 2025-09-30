// lib/widgets/audio_player_handler.dart
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/radio_station.dart'; 
// Importamos o modelo para usar o método estático saveStation

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  AudioPlayerHandler() { _init(); }
  
  Future<void> _init() async {
    _player.icyMetadataStream.listen((metadata) {
      final mediaItemAtual = mediaItem.value;
      if (mediaItemAtual == null) return;
      final title = metadata?.info?.title;
      
      // O título pode vir no formato "Artista - Música", se for diferente do nome da rádio (album), atualiza.
      if (title != null && title.isNotEmpty && title != mediaItemAtual.album) {
        final novoMediaItem = mediaItemAtual.copyWith(title: title);
        mediaItem.add(novoMediaItem);
      }
    });
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }
  
  // Toca uma nova estação de rádio (Chamado pela UI)
  Future<void> playStation(RadioStation station) async {
    // Ação CRUCIAL: Salvar a estação no armazenamento local antes de tocar
    await RadioStation.saveStation(station); 
    
    final mediaItem = MediaItem(
      id: station.streamUrl, 
      album: station.name, // Usando o nome da rádio como álbum
      title: station.name, // Título inicial é o nome da rádio
      artist: station.location, 
      artUri: Uri.parse(station.artUrl)
    );
    
    await _player.setAudioSource(AudioSource.uri(Uri.parse(station.streamUrl)));
    this.mediaItem.add(mediaItem);
    play();
  }
  
  @override
  Future<void> play() => _player.play();
  
  @override
  Future<void> pause() => _player.pause();
  
  @override
  Future<void> stop() async {
    await _player.stop();
    mediaItem.add(null);
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
