// lib/layout/app_layout.dart

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';

// Imports dos seus arquivos
import '../services/radio_service.dart'; // Importar o serviço de rádio
import '../widgets/audio_player_handler.dart';
import '../models/radio_station.dart';
import '../pages/player_screen.dart';
import '../pages/station_list_screen.dart';


class AppLayout extends StatefulWidget {
  final AudioPlayerHandler audioHandler;
  
  const AppLayout({
    super.key,
    required this.audioHandler,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  // --- NOVAS VARIÁVEIS DE ESTADO ---
  late Future<List<RadioStation>> _stationsFuture;
  late bool _showingPlayer;

  // Cores Dinâmicas e Padrão
  Color _startColor = const Color(0xFF1D244D);
  Color _endColor = const Color(0xFF000000);
  final Color _defaultStartColor = const Color(0xFF1D244D);
  final Color _defaultEndColor = const Color(0xFF000000);
  Uri? _lastArtUri;

  @override
  void initState() {
    super.initState();
    // Inicia a busca pela lista de rádios
    _stationsFuture = RadioService().fetchRadioStations();
    // Define a tela inicial: mostra o player se já houver uma rádio tocando, senão mostra a lista.
    _showingPlayer = widget.audioHandler.mediaItem.value != null;
  }

  void _toggleScreen(bool showPlayer) {
    if (_showingPlayer != showPlayer) {
      setState(() {
        _showingPlayer = showPlayer;
        if (!showPlayer) {
          _startColor = _defaultStartColor;
          _endColor = _defaultEndColor;
        }
      });
    }
  }

  Future<void> _updateBackgroundColors(Uri artUri) async {
    final provider = CachedNetworkImageProvider(artUri.toString());
    final paletteGenerator = await PaletteGenerator.fromImageProvider(provider);

    if (mounted && artUri == _lastArtUri) {
      setState(() {
        _startColor =
            paletteGenerator.dominantColor?.color ?? _defaultStartColor;
        _endColor = paletteGenerator.darkMutedColor?.color ??
            paletteGenerator.darkVibrantColor?.color ??
            _defaultEndColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- USA O FUTUREBUILDER PARA GARANTIR QUE A LISTA DE RÁDIOS FOI CARREGADA ---
    return FutureBuilder<List<RadioStation>>(
      future: _stationsFuture,
      builder: (context, stationListSnapshot) {
        if (stationListSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (stationListSnapshot.hasError || !stationListSnapshot.hasData) {
          return const Center(child: Text('Erro ao carregar estações.', style: TextStyle(color: Colors.white)));
        }

        final stations = stationListSnapshot.data!;

        return StreamBuilder<MediaItem?>(
          stream: widget.audioHandler.mediaItem,
          builder: (context, mediaItemSnapshot) {
            final mediaItem = mediaItemSnapshot.data;

            if (_showingPlayer && mediaItem != null && mediaItem.artUri != _lastArtUri) {
              _lastArtUri = mediaItem.artUri;
              if (mediaItem.artUri != null) {
                _updateBackgroundColors(mediaItem.artUri!);
              }
            }
            
            final startColor = _showingPlayer ? _startColor : _defaultStartColor;
            final endColor = _showingPlayer ? _endColor : _defaultEndColor;

            // --- LÓGICA DE RESOLUÇÃO DA ESTAÇÃO CORRIGIDA ---
            RadioStation? playingStation;
            if (mediaItem != null) {
              playingStation = stations.firstWhere(
                (station) => station.streamUrl == mediaItem.id,
                orElse: () => stations.first, // Fallback para a primeira da lista online
              );
            }

            Widget currentPage;
            
            if (_showingPlayer) {
              // Garante que não tentamos mostrar o PlayerScreen sem uma estação
              if (playingStation != null) {
                 currentPage = PlayerScreen(
                    audioHandler: widget.audioHandler,
                    mediaItem: mediaItem,
                    station: playingStation,
                    onShowList: () => _toggleScreen(false),
                  );
              } else {
                // Se por algum motivo não houver estação, mostra a lista.
                currentPage = StationListScreen(
                  audioHandler: widget.audioHandler,
                  onShowPlayer: () => _toggleScreen(true),
                );
              }
            } else {
              currentPage = StationListScreen(
                audioHandler: widget.audioHandler,
                onShowPlayer: () => _toggleScreen(true),
              );
            }

            return AnimatedContainer(
              duration: const Duration(seconds: 1),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [startColor, endColor])),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: currentPage, // Note que removemos o SafeArea e Padding daqui
                                   // porque as telas internas (Player e Lista) já devem controlá-los.
              ),
            );
          },
        );
      },
    );
  }
}
