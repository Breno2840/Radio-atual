// lib/layout/app_layout.dart

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';

import '../services/radio_service.dart';
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
  late Future<List<RadioStation>> _stationsFuture;
  // O app agora sempre tentará mostrar o player primeiro.
  bool _showingPlayer = true; 

  Color _startColor = const Color(0xFF1D244D);
  Color _endColor = const Color(0xFF000000);
  final Color _defaultStartColor = const Color(0xFF1D244D);
  final Color _defaultEndColor = const Color(0xFF000000);
  Uri? _lastArtUri;

  @override
  void initState() {
    super.initState();
    _stationsFuture = RadioService().fetchRadioStations();
    // A lógica de qual tela mostrar foi movida para o build,
    // garantindo que temos a lista de rádios primeiro.
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
        _startColor = paletteGenerator.dominantColor?.color ?? _defaultStartColor;
        _endColor = paletteGenerator.darkMutedColor?.color ??
            paletteGenerator.darkVibrantColor?.color ??
            _defaultEndColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RadioStation>>(
      future: _stationsFuture,
      builder: (context, stationListSnapshot) {
        if (stationListSnapshot.connectionState == ConnectionState.waiting) {
          return Container(
             color: _defaultStartColor,
             child: const Center(child: CircularProgressIndicator(color: Colors.white))
          );
        }
        if (stationListSnapshot.hasError || !stationListSnapshot.hasData || stationListSnapshot.data!.isEmpty) {
          return Container(
            color: _defaultStartColor,
            child: const Center(child: Text('Não foi possível carregar as rádios.', style: TextStyle(color: Colors.white)))
          );
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

            RadioStation playingStation;
            if (mediaItem != null) {
              // Se uma rádio está tocando, encontra ela na lista
              playingStation = stations.firstWhere(
                (station) => station.streamUrl == mediaItem.id,
                orElse: () => stations.first, 
              );
            } else {
              // Se nenhuma rádio estiver tocando, define a primeira da lista como padrão
              playingStation = stations.first;
            }

            Widget currentPage;
            
            if (_showingPlayer) {
               currentPage = PlayerScreen(
                  audioHandler: widget.audioHandler,
                  mediaItem: mediaItem,
                  // Agora playingStation nunca será nulo aqui
                  station: playingStation,
                  onShowList: () => _toggleScreen(false),
                );
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
                body: currentPage,
              ),
            );
          },
        );
      },
    );
  }
}
