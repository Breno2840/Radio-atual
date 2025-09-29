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
    return StreamBuilder<MediaItem?>(
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
        
        // Cálculo do Espaço
        final screenHeight = MediaQuery.of(context).size.height;
        final screenPadding = MediaQuery.of(context).padding;
        const topWidgetHeight = 28 + 20 + 30; // Título + Botão
        
        final heightAdjustment = showMiniPlayer ? miniPlayerHeight + 10 : 0.0; 
        final availableHeight = screenHeight - screenPadding.top - screenPadding.bottom - topWidgetHeight - heightAdjustment;

        const crossAxisCount = 2;
        const mainAxisSpacing = 16.0;
        const crossAxisSpacing = 16.0;
        const numberOfRows = 3;

        final totalSpacing = mainAxisSpacing * (numberOfRows - 1);
        final desiredCardHeight = (availableHeight - totalSpacing) / numberOfRows;
        
        final screenWidth = MediaQuery.of(context).size.width;
        final totalHorizontalPadding = 16.0 * 2;
        final cardWidth = (screenWidth - totalHorizontalPadding - crossAxisSpacing) / crossAxisCount;

        final desiredAspectRatio = cardWidth / desiredCardHeight;

        // Utilizamos Stack para colocar a lista e o Mini-Player um sobre o outro
        return Stack(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Estações de Rádio',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    // Botão para voltar ao Player
                    IconButton(
                      icon: const Icon(Icons.music_note_rounded, color: Colors.white, size: 30),
                      onPressed: onShowPlayer, 
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    // Padding inferior para o GridView
                    padding: EdgeInsets.only(bottom: showMiniPlayer ? miniPlayerHeight + 10 : 0), 
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: crossAxisSpacing,
                      mainAxisSpacing: mainAxisSpacing,
                      childAspectRatio: desiredAspectRatio,
                    ),
                    itemCount: radioStations.length,
                    itemBuilder: (context, index) {
                      final station = radioStations[index];
                      return RadioGridItem(
                        station: station,
                        onTap: () => audioHandler.playStation(station),
                      );
                    },
                  ),
                ),
              ],
            ),

            // O Mini-Player Fixo no Rodapé da Lista
            if (showMiniPlayer && mediaItem != null && playingStation != null)
              Positioned(
                bottom: 0,
                left: -16, 
                right: -16, 
                child: MiniPlayer(
                  audioHandler: audioHandler,
                  mediaItem: mediaItem,
                  station: playingStation,
                  onTap: onShowPlayer, // Clicar leva para a tela cheia
                ),
              ),
          ],
        );
      }
    );
  }
}
