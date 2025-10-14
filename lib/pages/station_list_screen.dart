import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import '../models/radio_station.dart';
import '../services/radio_service.dart'; // Importar o novo serviço
import '../widgets/audio_player_handler.dart';
import '../widgets/radio_grid_item.dart';
import '../widgets/mini_player.dart';

// Convertido para StatefulWidget para poder buscar os dados na inicialização
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
  // Variável para guardar o resultado da busca na internet
  late Future<List<RadioStation>> _stationsFuture;

  @override
  void initState() {
    super.initState();
    // Inicia a busca pelas rádios assim que a tela é construída
    _stationsFuture = RadioService().fetchRadioStations();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: StreamBuilder<MediaItem?>(
        stream: widget.audioHandler.mediaItem,
        builder: (context, mediaItemSnapshot) {
          final mediaItem = mediaItemSnapshot.data;
          bool showMiniPlayer = mediaItem != null;

          // Usamos o FutureBuilder para lidar com os estados da requisição
          return FutureBuilder<List<RadioStation>>(
            future: _stationsFuture,
            builder: (context, stationListSnapshot) {
              // --- ESTADO DE CARREGAMENTO ---
              if (stationListSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              // --- ESTADO DE ERRO ---
              if (stationListSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Erro ao carregar as estações:\n${stationListSnapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                );
              }

              // --- ESTADO DE SUCESSO ---
              if (!stationListSnapshot.hasData || stationListSnapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Nenhuma estação de rádio encontrada.',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final stations = stationListSnapshot.data!;
              RadioStation? playingStation;

              if (mediaItem != null) {
                // Encontra a estação que está tocando na lista que veio da internet
                playingStation = stations.firstWhere(
                  (station) => station.streamUrl == mediaItem.id,
                  // Se não encontrar (improvável), pode definir um padrão ou lidar com o erro
                  orElse: () => stations.first, 
                );
              }

              const miniPlayerHeight = 70.0;
              const miniPlayerPadding = 10.0;

              // Os cálculos de layout permanecem os mesmos
              final screenWidth = MediaQuery.of(context).size.width;
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
                              onPressed: widget.onShowPlayer,
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
                          // Usa o tamanho da lista vinda da internet
                          itemCount: stations.length, 
                          itemBuilder: (context, index) {
                            final station = stations[index];
                            return RadioGridItem(
                              station: station,
                              onTap: () => widget.audioHandler.playStation(station),
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
                            audioHandler: widget.audioHandler,
                            mediaItem: mediaItem,
                            station: playingStation,
                            onTap: widget.onShowPlayer,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
