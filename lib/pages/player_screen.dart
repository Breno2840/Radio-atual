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
  StreamSubscription<PlaybackState>? _playbackStateSubscription;

  @override
  void initState() {
    super.initState();
    _playbackStateSubscription = widget.audioHandler.playbackState.listen((state) {
      final isPlaying = state.playing;
    });
  }

  @override
  void dispose() {
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
                // Timer removido
                const SizedBox(width: 48), // Espaço para manter alinhamento
                IconButton(
                  icon: const Icon(Icons.apps_rounded, color: Colors.white, size: 30),
                  onPressed: widget.onShowList,
                ),
              ],
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