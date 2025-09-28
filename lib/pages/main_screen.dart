// lib/pages/main_screen.dart (CORRIGIDO)
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import '../models/radio_station.dart';
import '../widgets/audio_player_handler.dart';
import 'player_screen.dart';
import 'station_list_screen.dart';

class MainScreen extends StatefulWidget {
  final AudioPlayerHandler audioHandler;

  const MainScreen({super.key, required this.audioHandler});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _showPlayer = true;

  void _toggleScreen(bool showPlayer) {
    setState(() {
      _showPlayer = showPlayer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: widget.audioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        RadioStation? playingStation;

        if (mediaItem != null) {
          // Se estiver tocando, pega a rádio ativa
          playingStation = radioStations.firstWhere(
            (station) => station.streamUrl == mediaItem.id,
            orElse: () => radioStations.first,
          );
        } else {
          // CORREÇÃO 1: Se nada estiver tocando, use a primeira rádio para mostrar a capa inicial.
          playingStation = radioStations.first;
        }

        // Se a tela é o Player OU (se a tela for a Lista MAS algo começou a tocar), volta para o Player.
        if (_showPlayer) {
          return PlayerScreen(
            audioHandler: widget.audioHandler,
            mediaItem: mediaItem,
            // CORREÇÃO 1: Passa sempre a estação, garantindo a renderização inicial
            station: playingStation, 
            onShowList: () => _toggleScreen(false), // CORREÇÃO 2: O ícone dos 3 tracinhos agora funciona
          );
        } else {
          // Se a tela é a Lista
          return StationListScreen(
            audioHandler: widget.audioHandler,
            onShowPlayer: () => _toggleScreen(true),
          );
        }
      },
    );
  }
}
