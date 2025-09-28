// lib/pages/station_list_screen.dart
import 'package:flutter/material.dart';
import '../models/radio_station.dart';
import '../widgets/audio_player_handler.dart';
import '../widgets/radio_grid_item.dart'; 

class StationListScreen extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  final VoidCallback onShowPlayer; // NOVA PROPRIEDADE

  const StationListScreen({
    super.key,
    required this.audioHandler,
    required this.onShowPlayer, // NOVO PARÂMETRO
  });

  @override
  Widget build(BuildContext context) {
    // Cálculo matemático (Mantido)
    final screenHeight = MediaQuery.of(context).size.height;
    final screenPadding = MediaQuery.of(context).padding;
    const topWidgetHeight = 28 + 20 + 30; // Ajuste para o novo IconButton
    final availableHeight = screenHeight - screenPadding.top - screenPadding.bottom - topWidgetHeight;

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

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Estações de Rádio',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            // NOVO: Botão para voltar ao player, se necessário.
            IconButton(
              icon: const Icon(Icons.music_note_rounded, color: Colors.white, size: 30),
              onPressed: onShowPlayer, // Chama a função de navegação
            ),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
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
                onTap: () {
                  audioHandler.playStation(station);
                  onShowPlayer(); // Volta para a tela do player após a seleção
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
