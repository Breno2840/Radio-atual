// lib/layout/app_layout.dart
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
  final Future<List<RadioStation>> radioStationsFuture;

  const AppLayout({
    super.key,
    required this.audioHandler,
    required this.radioStationsFuture,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  Color _startColor = const Color(0xFF1D244D);
  Color _endColor = const Color(0xFF000000);
  final Color _defaultStartColor = const Color(0xFF1D244D);
  final Color _defaultEndColor = const Color(0xFF000000);
  Uri? _lastArtUri;
  bool _showingPlayer = true;

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
    return FutureBuilder<List<RadioStation>>(
      future: widget.radioStationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    'Sem conexão com a internet',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Verifique sua conexão e tente novamente.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Força o reload da Future
                      setState(() {});
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Tentar novamente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final radioStations = snapshot.data!;

        return StreamBuilder<MediaItem?>(
          stream: widget.audioHandler.mediaItem,
          builder: (context, mediaSnapshot) {
            final mediaItem = mediaSnapshot.data;

            if (_showingPlayer && mediaItem != null && mediaItem.artUri != _lastArtUri) {
              _lastArtUri = mediaItem.artUri;
              if (mediaItem.artUri != null) {
                _updateBackgroundColors(mediaItem.artUri!);
              }
            }

            final startColor = _showingPlayer ? _startColor : _defaultStartColor;
            final endColor = _showingPlayer ? _endColor : _defaultEndColor;

            RadioStation? playingStation;
            if (mediaItem != null) {
              playingStation = radioStations.firstWhere(
                (station) => station.streamUrl == mediaItem.id,
                orElse: () => radioStations.first,
              );
            } else {
              playingStation = radioStations.first;
            }

            Widget currentPage;
            if (_showingPlayer) {
              currentPage = PlayerScreen(
                audioHandler: widget.audioHandler,
                mediaItem: mediaItem,
                station: playingStation!,
                onShowList: () => _toggleScreen(false),
              );
            } else {
              currentPage = StationListScreen(
                audioHandler: widget.audioHandler,
                onShowPlayer: () => _toggleScreen(true),
                radioStationsFuture: widget.radioStationsFuture,
              );
            }

            return AnimatedContainer(
              duration: const Duration(seconds: 1),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [startColor, endColor],
                ),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: currentPage,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}