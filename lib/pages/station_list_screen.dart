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
    return FutureBuilder<List<RadioStation>>(
      future: RadioStation.fetchStations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  // Aqui você pode adicionar navegação se necessário
                },
              ),
              title: const Text(
                'Estações de Rádio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              centerTitle: false,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  // Aqui você pode adicionar navegação se necessário
                },
              ),
              title: const Text(
                'Estações de Rádio',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              centerTitle: false,
            ),
            body: Center(
              child: Text(
                'Erro ao carregar estações: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        final stations = snapshot.data ?? [];
        return _buildBody(context, stations);
      },
    );
  }

  Widget _buildBody(BuildContext context, List<RadioStation> stations) {
    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, mediaSnapshot) {
        final mediaItem = mediaSnapshot.data;
        RadioStation? playingStation;
        bool showMiniPlayer = false;

        if (mediaItem != null) {
          showMiniPlayer = true;
          playingStation = stations.firstWhere(
            (station) => station.streamUrl == mediaItem.id,
            orElse: () => stations.first,
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Aqui você pode adicionar navegação se necessário
              },
            ),
            title: const Text(
              'Estações de Rádio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            centerTitle: false,
          ),
          body: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: showMiniPlayer ? 90.0 : 16.0,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    final station = stations[index];
                    final isPlaying = mediaItem != null && 
                                     station.streamUrl == mediaItem.id;
                    
                    return RadioGridItem(
                      station: station,
                      isPlaying: isPlaying,
                      onTap: () => audioHandler.playStation(station),
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: showMiniPlayer && mediaItem != null && playingStation != null
              ? MiniPlayer(
                  audioHandler: audioHandler,
                  mediaItem: mediaItem,
                  station: playingStation,
                  onTap: onShowPlayer,
                )
              : null,
        );
      },
    );
  }
}