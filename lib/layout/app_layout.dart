import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:collection/collection.dart'; // Importar o pacote

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
  bool _isLoadingStations = true;

  @override
  void initState() {
    super.initState();
    print('🎨 AppLayout: initState');
    _loadStations();
  }

  Future<void> _loadStations() async {
    try {
      print('📡 AppLayout: Carregando estações...');
      final stations = await RadioStation.fetchStations();
      print('✅ AppLayout: ${stations.length} estações carregadas');

      if (mounted) {
        setState(() {
          _stations = stations;
          _isLoadingStations = false;
        });
      }
    } catch (e) {
      print('❌ AppLayout: Erro ao carregar estações: $e');
      if (mounted) {
        setState(() {
          _stations = [];
          _isLoadingStations = false;
        });
      }
    }
  }

  void _toggleScreen(bool showPlayer) {
    print('🔄 AppLayout: Alternando para ${showPlayer ? "Player" : "Lista"}');
    if (_showingPlayer != showPlayer) {
      setState(() {
        _showingPlayer = showPlayer;
      });
    }
  }

  Future<void> _updateBackgroundColors(Uri artUri) async {
    try {
      print('🎨 AppLayout: Atualizando cores do fundo...');
      final provider = CachedNetworkImageProvider(artUri.toString());
      final paletteGenerator = await PaletteGenerator.fromImageProvider(provider);

      if (mounted && artUri == _lastArtUri) {
        setState(() {
          _startColor = paletteGenerator.dominantColor?.color ?? _defaultStartColor;
          _endColor = paletteGenerator.darkMutedColor?.color ??
              paletteGenerator.darkVibrantColor?.color ??
              _defaultEndColor;
        });
        print('✅ AppLayout: Cores atualizadas');
      }
    } catch (e) {
      print('⚠️ AppLayout: Erro ao gerar paleta: $e');
    }
  }

  RadioStation? _findPlayingStation(MediaItem? mediaItem) {
    if (mediaItem == null || _stations.isEmpty) {
      return null;
    }
    
    // MELHORIA: Usando firstWhereOrNull para evitar exceções.
    return _stations.firstWhereOrNull(
      (station) => station.streamUrl.trim() == mediaItem.id.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ AppLayout: build (showingPlayer: $_showingPlayer)');

    return WillPopScope(
      onWillPop: () async {
        if (!_showingPlayer) {
          print('⬅️ AppLayout: Botão voltar - retornando ao player');
          _toggleScreen(true);
          return false;
        }
        print('⬅️ AppLayout: Botão voltar - saindo do app');
        return true;
      },
      child: StreamBuilder<MediaItem?>(
        stream: widget.audioHandler.mediaItem,
        builder: (context, snapshot) {
          final mediaItem = snapshot.data;

          // Atualiza cores quando muda a arte
          if (_showingPlayer && mediaItem != null && mediaItem.artUri != _lastArtUri) {
            _lastArtUri = mediaItem.artUri;
            if (mediaItem.artUri != null) {
              _updateBackgroundColors(mediaItem.artUri!);
            }
          }

          // Busca a estação que está tocando
          final playingStation = _findPlayingStation(mediaItem);

          // Mostra loading enquanto carrega estações
          if (_isLoadingStations) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_listStartColor, _listEndColor],
                ),
              ),
              child: const Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        'Carregando estações...',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Se não tem estações, mostra erro
          if (_stations.isEmpty) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_listStartColor, _listEndColor],
                ),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 20),
                        const Text(
                          'Erro ao carregar estações',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Verifique sua conexão com a internet',
                          style: TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isLoadingStations = true;
                            });
                            _loadStations();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          // Define a página atual
          Widget currentPage;

          if (_showingPlayer) {
            // Se não tem MediaItem, usa a primeira estação
            final stationToShow = playingStation ?? _stations.first;

            currentPage = PlayerScreen(
              audioHandler: widget.audioHandler,
              mediaItem: mediaItem,
              station: stationToShow,
              stations: _stations,
              onShowList: () => _toggleScreen(false),
            );
          } else {
            currentPage = Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => _toggleScreen(true),
                ),
                title: const Text(
                  'Estações de Rádio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                centerTitle: false,
              ),
              body: StationListScreen(
                audioHandler: widget.audioHandler,
                onShowPlayer: () => _toggleScreen(true),
              ),
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
            child: currentPage,
          );
        },
      ),
    );
  }
}
