import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../models/radio_station.dart'; 

MediaItem createMediaItem(RadioStation station) {
  return MediaItem(
    id: station.streamUrl.trim(), 
    album: station.name, 
    title: station.name, 
    artist: station.location, 
    artUri: Uri.parse(station.artUrl)
  );
}

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  AudioPlayerHandler() { _init(); }
  
  Future<void> _init() async {
    print('🎵 AudioHandler: Inicializando...');
    
    _player.icyMetadataStream.listen((metadata) {
      final mediaItemAtual = mediaItem.value;
      if (mediaItemAtual == null) return;
      final title = metadata?.info?.title;
      
      if (title != null && title.isNotEmpty && title != mediaItemAtual.album) {
        print('🎵 AudioHandler: Novo título ICY: $title');
        final novoMediaItem = mediaItemAtual.copyWith(title: title);
        mediaItem.add(novoMediaItem);
      }
    });

    _player.playerStateStream.listen((state) {
      print('🎵 AudioHandler: Estado: ${state.processingState} | Playing: ${state.playing}');
    }, onError: (error) {
      print('❌ AudioHandler: Erro no player: $error');
    });

    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    
    print('✅ AudioHandler: Inicializado com sucesso');
  }

  Future<void> loadStation(RadioStation station) async {
    print('📥 AudioHandler: Carregando estação: ${station.name}');
    final item = createMediaItem(station);
    mediaItem.add(item);
    print('✅ AudioHandler: MediaItem carregado (sem tocar)');
  }
  
  @override
  Future<void> playStation(RadioStation station) async {
    try {
      print('═══════════════════════════════════════');
      print('🎵 AudioHandler: INICIANDO PLAYBACK');
      print('📻 Estação: ${station.name}');
      print('📡 URL: ${station.streamUrl}');
      print('═══════════════════════════════════════');
      
      if (_player.playing) {
        print('⏹️ AudioHandler: Parando player anterior...');
        await _player.stop();
      }
      
      await RadioStation.saveStation(station);
      print('💾 AudioHandler: Estação salva');
      
      final item = createMediaItem(station);
      print('📦 AudioHandler: MediaItem criado');
      
      mediaItem.add(item);
      print('✅ AudioHandler: MediaItem ADICIONADO ao stream');
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      print('⏳ AudioHandler: Carregando stream...');
      
      // ✅ CONFIGURAÇÃO MELHORADA para lidar com redirects e diferentes formatos
      final audioSource = AudioSource.uri(
        Uri.parse(station.streamUrl.trim()),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36',
          'Accept': '*/*',
          'Connection': 'keep-alive',
        },
      );
      
      // Configura com timeout maior para streams que fazem redirect
      await _player.setAudioSource(
        audioSource,
        preload: true,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timeout ao conectar com a rádio. Verifique sua conexão.');
        },
      );
      
      print('✅ AudioHandler: Stream carregado');
      
      await play();
      
      print('═══════════════════════════════════════');
      print('✅ PLAYBACK INICIADO COM SUCESSO!');
      print('═══════════════════════════════════════');
      
    } catch (e, stackTrace) {
      print('═══════════════════════════════════════');
      print('❌❌❌ ERRO AO TOCAR ${station.name}');
      
      // ✅ MENSAGENS DE ERRO MAIS AMIGÁVEIS
      String errorMessage = 'Erro desconhecido';
      
      if (e.toString().contains('SocketException')) {
        errorMessage = 'Sem conexão com a internet';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Tempo esgotado ao conectar';
      } else if (e.toString().contains('HttpException')) {
        errorMessage = 'Erro ao acessar o servidor';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Formato de áudio não suportado';
      } else if (e.toString().contains('PlayerException')) {
        errorMessage = 'Erro no player de áudio';
      } else if (e.toString().contains('PlatformException')) {
        errorMessage = 'Erro na plataforma';
      } else if (e.toString().contains('Timeout')) {
        errorMessage = 'Conexão muito lenta';
      } else {
        errorMessage = e.toString().split('\n').first;
      }
      
      print('❌ Erro: $errorMessage');
      print('❌ Detalhes técnicos: ${e.runtimeType}');
      print('═══════════════════════════════════════');
      
      // Limpa o estado
      mediaItem.add(null);
      
      // Re-lança com mensagem amigável
      throw Exception(errorMessage);
    }
  }
  
  @override
  Future<void> play() async {
    try {
      await _player.play();
      print('▶️ AudioHandler: Play executado');
    } catch (e) {
      print('❌ AudioHandler: Erro ao executar play: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> pause() async {
    try {
      await _player.pause();
      print('⏸️ AudioHandler: Pause executado');
    } catch (e) {
      print('❌ AudioHandler: Erro ao executar pause: $e');
    }
  }
  
  @override
  Future<void> stop() async {
    try {
      await _player.stop();
      mediaItem.add(null);
      await super.stop();
      print('⏹️ AudioHandler: Stop executado');
    } catch (e) {
      print('❌ AudioHandler: Erro ao executar stop: $e');
    }
  }

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

  @override
  Future<void> onTaskRemoved() async {
    await stop();
    await _player.dispose();
    await super.onTaskRemoved();
  }
}