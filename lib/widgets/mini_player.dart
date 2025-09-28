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
    // Título e Subtítulo
    final String actualTitle = mediaItem.title;
    final bool hasSongTitle = actualTitle != station.name;
    final String displayTitle = hasSongTitle ? actualTitle : station.name;
    final String displaySubtitle = hasSongTitle ? station.name : station.location;
    final artUri = mediaItem.artUri;

    return GestureDetector(
      onTap: onTap, 
      child: Container(
        height: 70 + MediaQuery.of(context).padding.bottom, 
        padding: EdgeInsets.fromLTRB(10, 10, 10, MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade900.withOpacity(0.9), 
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, spreadRadius: 1)
          ],
        ),
        child: Row(
          children: [
            // Capa da Rádio
            ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: SizedBox(
                width: 50,
                height: 50,
                child: artUri != null
                    ? CachedNetworkImage(imageUrl: artUri.toString(), fit: BoxFit.cover)
                    : const Icon(Icons.radio, color: Colors.white70),
              ),
            ),
            const SizedBox(width: 10),

            // Títulos
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    displaySubtitle,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Controles de Áudio (Play/Pause)
            StreamBuilder<PlaybackState>(
              stream: audioHandler.playbackState,
              builder: (context, snapshot) {
                final playing = snapshot.data?.playing ?? false;
                final processing = snapshot.data?.processingState;

                if (processing == AudioProcessingState.loading || processing == AudioProcessingState.buffering) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
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
    );
  }
}
