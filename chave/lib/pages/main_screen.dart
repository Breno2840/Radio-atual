// lib/pages/main_screen.dart
import 'package:flutter/material.dart';
import '../widgets/audio_player_handler.dart';
import 'station_list_screen.dart';

// O MainScreen agora é um StatelessWidget que SEMPRE mostra a lista de estações
class MainScreen extends StatelessWidget {
  final AudioPlayerHandler audioHandler;

  const MainScreen({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return StationListScreen(
      audioHandler: audioHandler,
    );
  }
}
