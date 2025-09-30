// lib/widgets/audio_player_handler.dart

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/radio_station.dart'; // <--- Import Adicionado

// O seu Player Handler (Gerenciador de Áudio em Segundo Plano)
class AudioPlayerHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  // Estado que combina o player, volume e erro
  final _playerState = BehaviorSubject<PlaybackState>.seeded(const PlaybackState());

  AudioPlayerHandler() {
    // Escuta o estado do player JustAudio e o mapeia para o AudioService
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    // Conecta o player ao AudioService para o controle remoto (notificação, fones)
    _player.setAudioSource(ConcatenatingAudioSource(children: []));
  }

  // Mapeia eventos do JustAudio para PlaybackState do AudioService
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        _player.playing ? MediaControl.pause : MediaControl.play,
        // Mantemos apenas Play/Pause, pois é uma rádio ao vivo
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek, 
        MediaAction.seekForward, 
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1], // Play/Pause e Stop
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }

  // Cria a MediaItem com base na estação de rádio
  MediaItem createMediaItem(RadioStation station) {
    return MediaItem(
      id: station.streamUrl,
      album: station.band,
      title: station.name,
      artist: '${station.frequency} ${station.band}',
      artUri: Uri.parse(station.artUrl),
      extras: {
        'location': station.location,
        'frequency': station.frequency,
      },
      duration: Duration.zero, // Rádios ao vivo não têm duração definida
    );
  }

  // --- MÉTODOS DE CONTROLE ---

  // Toca uma nova estação de rádio (Chamado pelo PlayerListScreen)
  Future<void> playStation(RadioStation station) async {
    // 1. Salva a rádio no armazenamento local
    await RadioStation.saveLastPlayed(station.streamUrl); // <--- ADICIONADO

    final mediaItem = createMediaItem(station);
    await super.setMediaItem(mediaItem);
    await super.play();
  }

  @override
  Future<void> play() async {
    // Se o ID for a URL, define a fonte de áudio e toca
    if (mediaItem.value != null) {
      final url = mediaItem.value!.id;
      // Define a fonte de áudio e prepara o player
      await _player.setAudioSource(
        // A rádio sempre começa do início, sem cache
        AudioSource.uri(Uri.parse(url)),
        initialPosition: Duration.zero,
        preload: true,
      );
    }
    await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    // Limpa a notificação e encerra o serviço
    await super.stop();
  }

  @override
  Future<void> setMediaItem(MediaItem mediaItem) => super.setMediaItem(mediaItem);
}
