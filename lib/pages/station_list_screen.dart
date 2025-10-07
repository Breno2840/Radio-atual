// lib/pages/station_list_screen.dart

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import '../models/radio_station.dart';
import '../widgets/audio_player_handler.dart';
import '../widgets/radio_grid_item.dart'; 
import '../widgets/mini_player.dart'; 

class StationListScreen extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  final VoidCallback onShowPlayer; 

  const StationListScreen({
    super.key,
    required this.audioHandler,
    required this.onShowPlayer, 
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: StreamBuilder<MediaItem?>(
        stream: audioHandler.mediaItem,
        builder: (context, snapshot) {
          final mediaItem = snapshot.data;
          RadioStation? playingStation;
          bool showMiniPlayer = false;

          if (mediaItem != null) {
            showMiniPlayer = true;
            playingStation = radioStations.firstWhere(
              (station) => station.streamUrl == mediaItem.id,
              orElse: () => radioStations.first,
            );
          }

          const miniPlayerHeight = 70.0;
          const miniPlayerPadding = 10.0;

          final screenHeight = MediaQuery.of(context).size.height;
          final screenWidth = MediaQuery.of(context).size.width;
          final padding = MediaQuery.of(context).padding;

          // Altura do cabeçalho
          final headerHeight = 28.0 + 20.0 + 30.0;

          // Altura usada por elementos fixos
          final usedHeight = padding.top + headerHeight + (showMiniPlayer ? miniPlayerHeight + miniPlayerPadding : 0);
          final availableHeight = screenHeight - usedHeight - padding.bottom;

          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estações de Rádio',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(Icons.music_note_rounded, color: Colors.white, size: 28),
                          onPressed: onShowPlayer, 
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: 16.0,
                        right: 16.0,
                        bottom: showMiniPlayer ? miniPlayerHeight + miniPlayerPadding : 16.0,
                      ),
                      itemCount: radioStations.length,
                      itemBuilder: (context, index) {
                        final station = radioStations[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: RadioGridItem(
                            station: station,
                            onTap: () => audioHandler.playStation(station),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Mini Player fixo no rodapé
              if (showMiniPlayer && mediaItem != null && playingStation != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    bottom: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: MiniPlayer(
                        audioHandler: audioHandler,
                        mediaItem: mediaItem,
                        station: playingStation,
                        onTap: onShowPlayer,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}