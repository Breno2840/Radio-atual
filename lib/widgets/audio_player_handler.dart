import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/radio_station.dart'; 

// --- FUNÇÃO AUXILIAR DE CRIAÇÃO DO MEDIA ITEM ---
MediaItem createMediaItem(RadioStation station) {
  return MediaItem(
    id: station.streamUrl.trim(), 
    album: station.name, 
    title: station.name, 
    artist: station.location, 
    artUri: Uri.parse(station.artUrl)
  );
}
// -------------------------------------------------------------

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  AudioPlayerHandler() { _init(); }
  
  Future<void> _init() async {
    // ✅ Listener para metadados ICY (título da música)
    _player.icyMetadataStream.listen((metadata) {
      final mediaItemAtual = mediaItem.value;
      if (mediaItemAtual == null) return;
      final title = metadata?.info?.title;
      
      if (title != null && title.isNotEmpty && title != mediaItemAtual.album) {
        final novoMediaItem = mediaItemAtual.copyWith(title: title);
        mediaItem.add(novoMediaItem);
      }
    });

    // ✅ Listener de erros do player
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.idle && 
          state.playing == false && 
          mediaItem.value != null) {
        // Player parou inesperadamente
        print('⚠️ Player parou inesperadamente');
      }
    }, onError: (error) {
      print('❌ Erro no player: $error');
    });

    // ✅ Mapeia eventos de playback para o AudioService
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  // Carrega o MediaItem sem tocar (usado na inicialização)
  Future<void> loadStation(RadioStation station) async {
    final item = createMediaItem(station);
    mediaItem.add(item);
  }
  
  // ✅ MÉTODO CORRIGIDO - Com tratamento de erro completo
  Future<void> playStation(RadioStation station) async {
    try {
      print('🎵 Iniciando playback de: ${station.name}');
      print('📡 URL: ${station.streamUrl}');
      
      // 1. Salva a estação
      await RadioStation.saveStation(station);
      
      // 2. Cria o MediaItem ANTES de começar a tocar
      final item = createMediaItem(station);
      mediaItem.add(item);
      print('✅ MediaItem criado e adicionado');
      
      // 3. Para o player atual se estiver tocando
      if (_player.playing) {
        await _player.stop();
        print('⏹️ Player anterior parado');
      }
      
      // 4. Configura a nova fonte de áudio
      print('⏳ Carregando stream...');
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(station.streamUrl.trim()),
        ),
      );
      print('✅ Stream carregado');
      
      // 5. Inicia a reprodução
      await play();
      print('▶️ Reprodução iniciada');
      
    } catch (e, stackTrace) {
      print('❌ ERRO ao tocar ${station.name}:');
      print('   Erro: $e');
      print('   Stack: $stackTrace');
      
      // Limpa o estado em caso de erro
      mediaItem.add(null);
      
      // Re-lança o erro para ser tratado na UI
      rethrow;
    }
  }
  
  @override
  Future<void> play() async {
    try {
      await _player.play();
      print('✅ Play executado');
    } catch (e) {
      print('❌ Erro ao executar play: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> pause() async {
    try {
      await _player.pause();
      print('⏸️ Pause executado');
    } catch (e) {
      print('❌ Erro ao executar pause: $e');
    }
  }
  
  @override
  Future<void> stop() async {
    try {
      await _player.stop();
      mediaItem.add(null);
      await super.stop();
      print('⏹️ Stop executado');
    } catch (e) {
      print('❌ Erro ao executar stop: $e');
    }
  }

  // === MÉTODOS DE NAVEGAÇÃO ===
  int? _getCurrentIndex(String? streamUrl, List<RadioStation> stations) {
    if (streamUrl == null) return null;
    return stations.indexWhere((station) => station.streamUrl.trim() == streamUrl.trim());
  }

  Future<void> playNext(List<RadioStation> stations) async {
    final currentIndex = _getCurrentIndex(mediaItem.value?.id, stations);
    if (currentIndex == null || currentIndex >= stations.length - 1) return;
    await playStation(stations[currentIndex + 1]);
  }

  Future<void> playPrevious(List<RadioStation> stations) async {
    final currentIndex = _getCurrentIndex(mediaItem.value?.id, stations);
    if (currentIndex == null || currentIndex <= 0) return;
    await playStation(stations[currentIndex - 1]);
  }
  // ====================

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
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

  // ✅ MÉTODO DE LIMPEZA
  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await _player.dispose();
    await super.onTaskRemoved();
  }
}