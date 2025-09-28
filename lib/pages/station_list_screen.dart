// lib/pages/station_list_screen.dart
import 'package:flutter/material.dart';
import '../models/radio_station.dart';
import '../widgets/audio_player_handler.dart';
import '../widgets/radio_grid_item.dart'; 

class StationListScreen extends StatelessWidget {
  final AudioPlayerHandler audioHandler;

  const StationListScreen({
    super.key,
    required this.audioHandler,
  });

  @override
  Widget build(BuildContext context) {
    // Cálculo matemático (Ajustado)
    final screenHeight = MediaQuery.of(context).size.height;
    final screenPadding = MediaQuery.of(context).padding;
    const miniPlayerHeight = 70.0; // Altura do MiniPlayer
    const topWidgetHeight = 28 + 20; 

    // O MiniPlayer só aparece se houver áudio, mas o espaço na tela precisa ser considerado.
    // Vamos calcular o espaço de forma conservadora.
    final availableHeight = screenHeight - screenPadding.top - screenPadding.bottom - topWidgetHeight - miniPlayerHeight;

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
        // Título alinhado à esquerda
        const Padding(
          padding: EdgeInsets.only(top: 8.0, left: 0.0, right: 0.0), // Padding do MainScreen já foi aplicado
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Estações de Rádio',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
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
                // Ao clicar, apenas toca a rádio. A navegação permanece na lista.
                onTap: () => audioHandler.playStation(station),
              );
            },
          ),
        ),
        // Adiciona um espaço no final para que o último item não fique escondido atrás do MiniPlayer
        const SizedBox(height: 10), 
      ],
    );
  }
}
