import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audio_service/audio_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:device_info_plus/device_info_plus.dart';

// Imports dos seus arquivos
import 'pages/player_screen.dart';
import 'pages/station_list_screen.dart';
import 'models/radio_station.dart';
import 'widgets/audio_player_handler.dart';
// Note: O MiniPlayer não é importado aqui, ele é importado e usado no StationListScreen.

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent, statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light, systemNavigationBarIconBrightness: Brightness.light));
  
  if (Platform.isAndroid) {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      await Permission.notification.request();
    }
  }
  
  final audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.calculadora.my.channel.audio',
      androidNotificationChannelName: 'Reprodução de Áudio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    )
  );
  
  runApp(MyApp(audioHandler: audioHandler));
}

class MyApp extends StatefulWidget {
  final AudioPlayerHandler audioHandler;
  const MyApp({super.key, required this.audioHandler});
  
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color _startColor = const Color(0xFF1D244D);
  Color _endColor = const Color(0xFF000000);
  final Color _defaultStartColor = const Color(0xFF1D244D); 
  final Color _defaultEndColor = const Color(0xFF000000);   
  Uri? _lastArtUri;
  
  // Estado para controlar a tela atual: Player (true) ou Lista (false)
  bool _showingPlayer = true; 
  
  void _toggleScreen(bool showPlayer) {
    setState(() {
      _showingPlayer = showPlayer;
      // Quando alterna para a Lista, força o uso das cores escuras fixas
      if (!showPlayer) {
        _startColor = _defaultStartColor;
        _endColor = _defaultEndColor;
      }
    });
  }

  Future<void> _updateBackgroundColors(Uri artUri) async {
    final provider = CachedNetworkImageProvider(artUri.toString());
    final paletteGenerator = await PaletteGenerator.fromImageProvider(provider);
    if (mounted) {
      setState(() {
        _startColor = paletteGenerator.dominantColor?.color ?? _defaultStartColor;
        _endColor = paletteGenerator.darkMutedColor?.color ?? paletteGenerator.darkVibrantColor?.color ?? _defaultEndColor;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minha Rádio',
      theme: ThemeData.dark(),
      home: StreamBuilder<MediaItem?>(
        stream: widget.audioHandler.mediaItem,
        builder: (context, snapshot) {
          final mediaItem = snapshot.data;
          
          // Lógica de Cor Dinâmica: SÓ se estiver no Player e com MediaItem
          if (_showingPlayer && mediaItem != null && mediaItem.artUri != _lastArtUri) {
            _lastArtUri = mediaItem.artUri;
            if (mediaItem.artUri != null) {
               _updateBackgroundColors(mediaItem.artUri!);
            }
          }
          
          // Cores usadas: Dinâmicas se for Player, ou as Cores fixas
          final startColor = _showingPlayer ? _startColor : _defaultStartColor;
          final endColor = _showingPlayer ? _endColor : _defaultEndColor;

          RadioStation? playingStation;
          if (mediaItem != null) {
            playingStation = radioStations.firstWhere(
              (station) => station.streamUrl == mediaItem.id,
              orElse: () => radioStations.first
            );
          } else {
             // Garante que o Player inicie com a primeira rádio como placeholder (para a capa)
             playingStation = radioStations.first;
          }
          
          // Define a tela a ser exibida
          Widget currentPage;
          if (_showingPlayer || playingStation != null) {
            // PlayerScreen (Tela Inicial)
            currentPage = PlayerScreen(
              audioHandler: widget.audioHandler,
              mediaItem: mediaItem,
              station: playingStation!,
              onShowList: () => _toggleScreen(false), 
            );
          } else {
            // StationListScreen (Acessada pelo ícone)
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
                colors: [startColor, endColor]
              )
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent, 
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: currentPage,
                ),
              ),
              bottomNavigationBar: null, 
            ),
          );
        },
      ),
    );
  }
}
