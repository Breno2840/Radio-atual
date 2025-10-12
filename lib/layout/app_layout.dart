import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';

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
  // Cores Dinâmicas para o Player
  Color _startColor = const Color(0xFF1D244D);
  Color _endColor = const Color(0xFF000000);
  final Color _defaultStartColor = const Color(0xFF1D244D);
  final Color _defaultEndColor = const Color(0xFF000000);
  Uri? _lastArtUri;

  // Cores do gradiente escuro para a lista
  final Color _listStartColor = const Color(0xFF1a1a2e);
  final Color _listEndColor = const Color(0xFF0f0f1e);

  bool _showingPlayer = true;
  List<RadioStation> _stations = [];

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    try {
      final stations = await RadioStation.fetchStations();
      if (mounted) {
        setState(() {
          _stations = stations;
        });
      }
    } catch (e) {
      // Em caso de erro, você pode exibir uma mensagem ou manter uma lista vazia
      if (mounted) {
        setState(() {
          _stations = [];
        });
      }
    }
  }

  void _toggleScreen(bool showPlayer) {
    if (_showingPlayer != showPlayer) {
      setState(() {
        _showingPlayer = showPlayer;
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
    return StreamBuilder<MediaItem?>(
      stream: widget.audioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;

        if (_showingPlayer && mediaItem != null && mediaItem.artUri != _lastArtUri) {
          _lastArtUri = mediaItem.artUri;
          if (mediaItem.artUri != null) {
            _updateBackgroundColors(mediaItem.artUri!);
          }
        }

        RadioStation? playingStation;
        if (mediaItem != null && _stations.isNotEmpty) {
          playingStation = _stations.firstWhere(
            (station) => station.streamUrl == mediaItem.id,
            orElse: () => _stations.first,
          );
        } else if (_stations.isNotEmpty) {
          playingStation = _stations.first;
        }

        Widget currentPage;
        
        if (_showingPlayer) {
          if (_stations.isEmpty) {
            // Caso as estações ainda estejam carregando ou falharam
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          currentPage = PlayerScreen(
            audioHandler: widget.audioHandler,
            mediaItem: mediaItem,
            station: playingStation!,
            stations: _stations,
            onShowList: () => _toggleScreen(false),
          );
        } else {
          currentPage = StationListScreen(
            audioHandler: widget.audioHandler,
            onShowPlayer: () => _toggleScreen(true),
          );
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _showingPlayer 
                  ? [_startColor, _endColor]
                  : [_listStartColor, _listEndColor],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: currentPage,
          ),
        );
      },
    );
  }
}