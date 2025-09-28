import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../models/radio_station.dart';
import '../widgets/audio_player_handler.dart'; 

class PlayerScreen extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  final MediaItem? mediaItem; 
  final RadioStation station; 
  final VoidCallback onShowList; 

  const PlayerScreen({
    super.key,
    required this.audioHandler,
    required this.mediaItem,
    required this.station, 
    required this.onShowList, 
  });

  @override
  Widget build(BuildContext context) {
    final artUri = mediaItem?.artUri ?? Uri.parse(station.artUrl); 
    
    final String actualTitle = mediaItem?.title ?? station.name;
    final bool hasSongTitle = actualTitle != station.name;
    final String displayTitle = hasSongTitle ? actualTitle : '${station.name} ${station.frequency}';
    final String displaySubtitle = hasSongTitle ? station.name : station.location;
    
    return Column(
      children: [
        // Botão para ir para a lista (3 tracinhos)
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 30),
            onPressed: onShowList, 
          ),
        ),
        
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))]
                ),
                child: ClipRRect( 
                  borderRadius: BorderRadius.circular(20.0),
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: CachedNetworkImage(
                      imageUrl: artUri.toString(),
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.music_note, size: 100)
                    )
                  )
                )
              ),
              const SizedBox(height: 40),
              // CORREÇÃO: Estilo do texto ajustado para evitar sublinhado e garantir o tamanho
              Text(
                displayTitle,
                style: const TextStyle(
                  fontSize: 26, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white,
                  decoration: TextDecoration.none, 
                ),
                textAlign: TextAlign.center,
                maxLines: 2, 
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                displaySubtitle,
                style: TextStyle(
                  fontSize: 18, 
                  color: Colors.white.withOpacity(0.7),
                  decoration: TextDecoration.none,
                )
              ),
              const SizedBox(height: 40),
              StreamBuilder<PlaybackState>(
                stream: audioHandler.playbackState,
                builder: (context, snapshot) {
                  final playbackState = snapshot.data;
                  final processingState = playbackState?.processingState;
                  final playing = playbackState?.playing ?? false;
                  
                  if (processingState == AudioProcessingState.loading || processingState == AudioProcessingState.buffering) {
                    return const SizedBox(width: 80, height: 80, child: CircularProgressIndicator(color: Colors.white));
                  } else {
                    return GlassmorphicContainer(
                      width: 220,
                      height: 80,
                      borderRadius: 40,
                      blur: 10,
                      alignment: Alignment.center,
                      border: 2,
                      linearGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.2)]
                      ),
                      borderGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white.withOpacity(0.5), Colors.white.withOpacity(0.5)]
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!playing)
                            IconButton(
                              icon: const Icon(Icons.play_arrow_rounded),
                              iconSize: 50.0,
                              color: Colors.white,
                              onPressed: () => audioHandler.playStation(station),
                            )
                          else ...[
                            IconButton(
                              icon: const Icon(Icons.pause_rounded),
                              iconSize: 50.0,
                              color: Colors.white,
                              onPressed: audioHandler.pause
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: const Icon(Icons.stop_rounded),
                              iconSize: 50.0,
                              color: Colors.white.withOpacity(0.8),
                              onPressed: audioHandler.stop
                            )
                          ]
                        ]
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
