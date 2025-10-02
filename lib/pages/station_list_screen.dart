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
  final Future<List<RadioStation>> radioStationsFuture;

  const StationListScreen({
    super.key,
    required this.audioHandler,
    required this.onShowPlayer,
    required this.radioStationsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: FutureBuilder<List<RadioStation>>(
        future: radioStationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (snapshot.hasError) {
            return _buildErrorScreen(() => radioStationsFuture);
          }

          final radioStations = snapshot.data!;
          return _buildStationList(context, radioStations);
        },
      ),
    );
  }

  Widget _buildErrorScreen(VoidCallback onRetry) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              'Sem conexão com a internet',
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Verifique sua conexão e tente novamente.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationList(BuildContext context, List<RadioStation> radioStations) {
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
        const miniPlayerPadding = 10.0;
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        final padding = MediaQuery.of(context).padding;
        final headerHeight = 28.0 + 20.0 + 30.0;
        final usedHeight = padding.top + headerHeight + (showMiniPlayer ? miniPlayerHeight + miniPlayerPadding : 0);
        final availableHeight = screenHeight - usedHeight - padding.bottom;
        final safeAvailableHeight = availableHeight > 100 ? availableHeight : 100;

        const crossAxisCount = 2;
        const mainAxisSpacing = 16.0;
        const crossAxisSpacing = 16.0;
        const horizontalPadding = 16.0 * 2;
        final cardWidth = (screenWidth - horizontalPadding - crossAxisSpacing) / crossAxisCount;
        final cardHeight = cardWidth * 1.2;
        final childAspectRatio = cardWidth / cardHeight;

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
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: showMiniPlayer ? miniPlayerHeight + miniPlayerPadding : 16.0,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: crossAxisSpacing,
                      mainAxisSpacing: mainAxisSpacing,
                      childAspectRatio: childAspectRatio,
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
    );
  }
}