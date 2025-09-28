// lib/pages/main_screen.dart (SIMPLIFICADO)
import 'package:flutter/material.dart';
import '../widgets/audio_player_handler.dart';
import 'player_screen.dart'; // Ainda é referenciado para usar a rádio padrão, mas não mais o widget principal.
import 'station_list_screen.dart';
import '../models/radio_station.dart';

// O MainScreen agora é um StatelessWidget simples que SEMPRE mostra a lista de estações
// (a navegação para o Player Cheio é feita pelo MiniPlayer)
class MainScreen extends StatelessWidget {
  final AudioPlayerHandler audioHandler;

  const MainScreen({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    // O MainScreen agora apenas mostra a lista de estações.
    // O MiniPlayer cuidará da navegação para a tela cheia do Player.
    return StationListScreen(
      audioHandler: audioHandler,
      // Não precisamos mais do onShowPlayer, pois a navegação é via Mini-Player
    );
  }
}
