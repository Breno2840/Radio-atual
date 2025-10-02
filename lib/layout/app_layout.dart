import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';

import '../widgets/audio_player_handler.dart';
import '../pages/player_screen.dart';
import '../pages/station_list_screen.dart';

class AppLayout extends StatefulWidget {
  final AudioPlayerHandler audioHandler;

  const AppLayout({super.key, required this.audioHandler});

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

        Widget currentPage;
        if (_showingPlayer) {
          currentPage = PlayerScreen(
            audioHandler: widget.audioHandler,
            mediaItem: mediaItem,
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
  }
}