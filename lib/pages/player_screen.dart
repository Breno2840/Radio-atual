import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../models/radio_station.dart';
import '../widgets/audio_player_handler.dart';

class PlayerScreen extends StatefulWidget {
  final AudioPlayerHandler audioHandler;
  final MediaItem? mediaItem;
  final RadioStation station;
  final List<RadioStation> stations; // Nova propriedade
  final VoidCallback onShowList;

  const PlayerScreen({
    super.key,
    required this.audioHandler,
    required this.mediaItem,
    required this.station,
    required this.stations, // Adicionado
    required this.onShowList,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  Timer? _sleepTimer;
  int? _remainingSeconds;
  StreamSubscription<PlaybackState>? _playbackStateSubscription;

  @override
  void initState() {
    super.initState();
    _playbackStateSubscription = widget.audioHandler.playbackState.listen((state) {
      final isPlaying = state.playing;
      if (_remainingSeconds != null) {
        if (isPlaying) {
          // Garante que o timer esteja rodando
          _ensureTimerIsRunning();
        } else {
          // Pausa o timer (cancela, mas mantém o tempo restante)
          _sleepTimer?.cancel();
          _sleepTimer = null;
        }
      }
    });
  }

  void _ensureTimerIsRunning() {
    if (_sleepTimer != null) return; // já está rodando
    if (_remainingSeconds == null || _remainingSeconds! <= 0) return;

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds! > 0) {
        setState(() {
          _remainingSeconds = _remainingSeconds! - 1;
        });
      } else {
        timer.cancel();
        widget.audioHandler.stop();
        _remainingSeconds = null;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.station.name} foi desligada pelo timer.')),
        );
      }
    });
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _remainingSeconds = null;
    setState(() {});
  }

  void _startSleepTimer(int minutes) {
    _cancelSleepTimer();
    _remainingSeconds = minutes * 60;
    _ensureTimerIsRunning();
  }

  void _showTimerDialog() {
    final isPlaying = widget.audioHandler.playbackState.value?.playing ?? false;
    if (!isPlaying) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Toque em play primeiro para ativar o timer.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desligar em...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTimerOption(15),
            _buildTimerOption(30),
            _buildTimerOption(45),
            _buildTimerOption(60),
            if (_remainingSeconds != null)
              TextButton(
                onPressed: () {
                  _cancelSleepTimer();
                  Navigator.pop(context);
                },
                child: const Text('Cancelar timer', style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerOption(int minutes) {
    return ListTile(
      title: Text('$minutes minutos'),
      onTap: () {
        Navigator.pop(context);
        _startSleepTimer(minutes);
      },
    );
  }

  String _formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _playbackStateSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final artUri = widget.mediaItem?.artUri ?? Uri.parse(widget.station.artUrl);

    final String actualTitle = widget.mediaItem?.title ?? widget.station.name;
    final bool hasSongTitle = actualTitle != widget.station.name;
    final String displayTitle = hasSongTitle ? actualTitle : '${widget.station.name} ${widget.station.frequency}';
    final String displaySubtitle = hasSongTitle ? widget.station.name : widget.station.location;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double imageSize = screenWidth * 0.7;
    final double buttonHeight = screenHeight * 0.08;
    final double buttonWidth = imageSize * 0.8;

    return SafeArea(
      bottom: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.access_alarm,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: _showTimerDialog,
                  tooltip: 'Definir timer para desligar',
                ),
                IconButton(
                  icon: const Icon(Icons.apps_rounded, color: Colors.white, size: 30),
                  onPressed: widget.onShowList,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_remainingSeconds != null)
            Text(
              'Desliga em: ${_formatTime(_remainingSeconds!)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.none, // ← Correção aplicada
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: SizedBox(
                      width: imageSize,
                      height: imageSize,
                      child: CachedNetworkImage(
                        imageUrl: artUri.toString(),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.music_note, size: 100),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  displayTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  displaySubtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 24),
                StreamBuilder<PlaybackState>(
                  stream: widget.audioHandler.playbackState,
                  builder: (context, snapshot) {
                    final playbackState = snapshot.data;
                    final processingState = playbackState?.processingState;
                    final playing = playbackState?.playing ?? false;

                    if (processingState == AudioProcessingState.loading ||
                        processingState == AudioProcessingState.buffering) {
                      return const SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    } else {
                      return GlassmorphicContainer(
                        width: buttonWidth,
                        height: buttonHeight,
                        borderRadius: 40,
                        blur: 10,
                        alignment: Alignment.center,
                        border: 2,
                        linearGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.2)
                          ],
                        ),
                        borderGradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.5),
                            Colors.white.withOpacity(0.5)
                          ],
                        ),
                        child: playing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.skip_previous_rounded),
                                    iconSize: buttonHeight * 0.6,
                                    color: Colors.white,
                                    onPressed: () => widget.audioHandler.playPrevious(widget.stations),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.pause_rounded),
                                    iconSize: buttonHeight * 0.6,
                                    color: Colors.white,
                                    onPressed: widget.audioHandler.pause,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.skip_next_rounded),
                                    iconSize: buttonHeight * 0.6,
                                    color: Colors.white,
                                    onPressed: () => widget.audioHandler.playNext(widget.stations),
                                  ),
                                ],
                              )
                            : IconButton(
                                icon: const Icon(Icons.play_arrow_rounded),
                                iconSize: buttonHeight * 0.6,
                                color: Colors.white,
                                onPressed: () => widget.audioHandler.playStation(widget.station),
                              ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}