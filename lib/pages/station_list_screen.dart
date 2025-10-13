import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import '../models/radio_station.dart';
import '../widgets/audio_player_handler.dart';
import '../widgets/radio_grid_item.dart';
import '../widgets/mini_player.dart';

class StationListScreen extends StatefulWidget {
  final AudioPlayerHandler audioHandler;
  final VoidCallback onShowPlayer;

  const StationListScreen({
    super.key,
    required this.audioHandler,
    required this.onShowPlayer,
  });

  @override
  State<StationListScreen> createState() => _StationListScreenState();
}

class _StationListScreenState extends State<StationListScreen> {
  late Future<List<RadioStation>> _futureStations;
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    _futureStations = RadioStation.fetchStations();
    _scrollController = ScrollController();
    
    // Debug: monitora mudanças no mediaItem
    widget.audioHandler.mediaItem.listen((item) {
      print('📻 StationList: MediaItem mudou: ${item?.title}');
      if (mounted) {
        setState(() {}); // Força rebuild quando mediaItem mudar
      }
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RadioStation>>(
      future: _futureStations,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
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
      stream: widget.audioHandler.mediaItem,
      builder: (context, mediaSnapshot) {
        final mediaItem = mediaSnapshot.data;
        RadioStation? playingStation;

        // Debug
        print('🔄 StationList: Rebuild - MediaItem: ${mediaItem?.title}');

        if (mediaItem != null) {
          try {
            playingStation = stations.firstWhere(
              (station) => station.streamUrl.trim() == mediaItem.id.trim(),
            );
            print('✅ StationList: Estação encontrada: ${playingStation.name}');
          } catch (e) {
            print('⚠️ StationList: Estação não encontrada para: ${mediaItem.id}');
            playingStation = null;
          }
        }

        final showMiniPlayer = mediaItem != null && playingStation != null;
        
        print('👀 StationList: showMiniPlayer = $showMiniPlayer');

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    top: 16.0,
                    bottom: showMiniPlayer ? 100.0 : 16.0,
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
                                     station.streamUrl.trim() == mediaItem.id.trim();

                    return RadioGridItem(
                      station: station,
                      isPlaying: isPlaying,
                      onTap: () async {
                        print('🎵 StationList: Clicou em: ${station.name}');
                        try {
                          await widget.audioHandler.playStation(station);
                          print('✅ StationList: Tocando: ${station.name}');
                        } catch (e) {
                          print('❌ StationList: Erro ao tocar: $e');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erro ao tocar ${station.name}'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          bottomNavigationBar: showMiniPlayer && playingStation != null
              ? SafeArea(
                  child: MiniPlayer(
                    audioHandler: widget.audioHandler,
                    mediaItem: mediaItem!,
                    station: playingStation,
                    onTap: widget.onShowPlayer,
                  ),
                )
              : null,
        );
      },
    );
  }
}