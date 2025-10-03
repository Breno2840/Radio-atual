import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';

// Imports dos seus arquivos
import '../widgets/audio_player_handler.dart';
import '../models/radio_station.dart';
import '../pages/player_screen.dart';
import '../pages/station_list_screen.dart';


class AppLayout extends StatefulWidget {
  // Recebe o handler e a estação inicial, igual ao antigo MyApp
  final AudioPlayerHandler audioHandler;
  
  const AppLayout({
    super.key,
    required this.audioHandler,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  // Cores Dinâmicas e Padrão
  Color _startColor = const Color(0xFF1D244D);
  Color _endColor = const Color(0xFF000000);
  final Color _defaultStartColor = const Color(0xFF1D244D);
  final Color _defaultEndColor = const Color(0xFF000000);
  Uri? _lastArtUri;

  // Estado para controlar a tela atual: Player (true) ou Lista (false)
  bool _showingPlayer = true;

  void _toggleScreen(bool showPlayer) {
    if (_showingPlayer != showPlayer) {
      setState(() {
        _showingPlayer = showPlayer;
        // Quando alterna para a Lista, força o uso das cores escuras fixas
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
    return StreamBuilder<MediaItem?>(
      stream: widget.audioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;

        // Lógica de Cor Dinâmica:
        if (_showingPlayer && mediaItem != null && mediaItem.artUri != _lastArtUri) {
          _lastArtUri = mediaItem.artUri;
          if (mediaItem.artUri != null) {
            _updateBackgroundColors(mediaItem.artUri!);
          }
        }

        // Cores usadas: Dinâmicas se for Player, ou as Cores fixas
        final startColor = _showingPlayer ? _startColor : _defaultStartColor;
        final endColor = _showingPlayer ? _endColor : _defaultEndColor;

        // Resolução da Estação (mantida aqui, pois depende do mediaItem)
        RadioStation? playingStation;
        if (mediaItem != null) {
          playingStation = radioStations.firstWhere(
            (station) => station.streamUrl == mediaItem.id,
            orElse: () => radioStations.first,
          );
        } else {
          // Garante que o Player inicie com a rádio padrão se o MediaItem estiver nulo
          playingStation = radioStations.first;
        }

        // Define a tela a ser exibida
        Widget currentPage;
        
        // Se estamos no modo Player OU se algo está tocando, mostramos o PlayerScreen
        if (_showingPlayer) {
          currentPage = PlayerScreen(
            audioHandler: widget.audioHandler,
            mediaItem: mediaItem,
            station: playingStation!,
            onShowList: () => _toggleScreen(false), // O botão no Player define _showingPlayer para false
          );
        } else {
          // Caso contrário, mostramos a Lista de Rádios
          currentPage = StationListScreen(
            audioHandler: widget.audioHandler,
            onShowPlayer: () => _toggleScreen(true), // O botão no MiniPlayer/Lista define _showingPlayer para true
          );
        }

        // Estrutura do Layout com Gradiente e Scaffold
        return AnimatedContainer(
          duration: const Duration(seconds: 1),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [startColor, endColor])),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: currentPage, // A tela que está sendo exibida.
              ),
            ),
            bottomNavigationBar: null,
          ),
        );
      },
    );
  }
}
