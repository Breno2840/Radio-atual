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
        height: 80, // Aumentado de 70 para 80
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2C2C2E).withOpacity(0.98),
              const Color(0xFF1C1C1E).withOpacity(0.98),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, -3),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            children: [
              // Logo da rádio - aumentado e com sombra
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 60, // Aumentado de 50 para 60
                    height: 60, // Aumentado de 50 para 60
                    color: Colors.white,
                    child: artUri != null
                        ? CachedNetworkImage(
                            imageUrl: artUri.toString(),
                            fit: BoxFit.cover,
                            httpHeaders: const {
                              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                            },
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.radio,
                                color: Colors.grey[600],
                                size: 32,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.radio,
                              color: Colors.grey[600],
                              size: 32,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 14), // Aumentado de 12 para 14

              // Informações da rádio - com mais espaço
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
                        fontSize: 15, // Aumentado de 14 para 15
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4), // Aumentado de 2 para 4
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            displaySubtitle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13, // Aumentado de 12 para 13
                              letterSpacing: 0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Botão Play/Pause - maior e com área de toque aumentada
              StreamBuilder<PlaybackState>(
                stream: audioHandler.playbackState,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  final processing = snapshot.data?.processingState;

                  if (processing == AudioProcessingState.loading ||
                      processing == AudioProcessingState.buffering) {
                    return Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(12),
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    );
                  }

                  return Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28, // Reduzido de 32 para 28 para caber melhor
                      ),
                      onPressed: playing ? audioHandler.pause : audioHandler.play,
                      padding: EdgeInsets.zero,
                      splashRadius: 24,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}