import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/radio_station.dart';
import '../widgets/audio_player_handler.dart';

class MiniPlayer extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  final MediaItem mediaItem;
  final RadioStation station;
  final VoidCallback onTap;

  const MiniPlayer({
    super.key,
    required this.audioHandler,
    required this.mediaItem,
    required this.station,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String actualTitle = mediaItem.title;
    final bool hasSongTitle = actualTitle != station.name;
    final String displayTitle = hasSongTitle ? actualTitle : station.name;
    final String displaySubtitle = hasSongTitle ? station.name : station.location;
    final artUri = mediaItem.artUri;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        margin: const EdgeInsets.only(bottom: 0),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E).withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                // Logo da rádio
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.white,
                    child: artUri != null
                        ? CachedNetworkImage(
                            imageUrl: artUri.toString(),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.radio,
                              color: Colors.grey[400],
                              size: 30,
                            ),
                          )
                        : Icon(
                            Icons.radio,
                            color: Colors.grey[400],
                            size: 30,
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Informações da rádio
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displaySubtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Botão Play/Pause
                StreamBuilder<PlaybackState>(
                  stream: audioHandler.playbackState,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;
                    final processing = snapshot.data?.processingState;

                    if (processing == AudioProcessingState.loading ||
                        processing == AudioProcessingState.buffering) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      );
                    }

                    return IconButton(
                      icon: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: playing ? audioHandler.pause : audioHandler.play,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}