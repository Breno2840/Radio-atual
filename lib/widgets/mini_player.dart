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

    const double borderRadiusValue = 16.0;

    return GestureDetector(
      onTap: onTap,
      // CORREÇÃO CRUCIAL: Envolvemos o Container com ClipRRect
      child: ClipRRect( 
        // Aplicamos o mesmo Border Radius que está no Container
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(borderRadiusValue),
          topRight: Radius.circular(borderRadiusValue),
        ),
        child: Container(
          height: 70 + MediaQuery.of(context).padding.bottom,
          padding: EdgeInsets.fromLTRB(
            16.0,
            10.0,
            16.0,
            MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E).withOpacity(0.95),
            // Mudei para only, mas se quiser todos, use circular(borderRadiusValue)
            borderRadius: const BorderRadius.only( 
              topLeft: Radius.circular(borderRadiusValue),
              topRight: Radius.circular(borderRadiusValue),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 1,
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 📀 Capa
              ClipRRect(
                borderRadius: BorderRadius.circular(6.0),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: artUri != null
                      ? CachedNetworkImage(
                          imageUrl: artUri.toString(),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        )
                      : const Icon(Icons.radio, color: Colors.white70, size: 40),
                ),
              ),
              const SizedBox(width: 10),

              // 📋 Títulos
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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

              // ▶️ Botão Play/Pause
              StreamBuilder<PlaybackState>(
                stream: audioHandler.playbackState,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  final processing = snapshot.data?.processingState;

                  if (processing == AudioProcessingState.loading ||
                      processing == AudioProcessingState.buffering) {
                    return const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    );
                  }

                  return IconButton(
                    icon: Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                    onPressed: playing ? audioHandler.pause : audioHandler.play,
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
