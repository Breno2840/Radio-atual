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
import 'pages/main_screen.dart'; 
import 'models/radio_station.dart';
import 'widgets/audio_player_handler.dart';
import 'widgets/mini_player.dart'; // NOVO: MiniPlayer

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
  Uri? _lastArtUri;
  
  Future<void> _updateBackgroundColors(Uri artUri) async {
    final provider = CachedNetworkImageProvider(artUri.toString());
    final paletteGenerator = await PaletteGenerator.fromImageProvider(provider);
    if (mounted) {
      setState(() {
        _startColor = paletteGenerator.dominantColor?.color ?? const Color(0xFF1D244D);
        _endColor = paletteGenerator.darkMutedColor?.color ?? paletteGenerator.darkVibrantColor?.color ?? Colors.black;
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
          
          if (mediaItem != null && mediaItem.artUri != _lastArtUri) {
            _lastArtUri = mediaItem.artUri;
            // Se o artUri não for nulo, chama a atualização de cor
            if (mediaItem.artUri != null) {
               _updateBackgroundColors(mediaItem.artUri!);
            }
          }
          
          final startColor = mediaItem != null ? _startColor : const Color(0xFF1D244D);
          final endColor = mediaItem != null ? _endColor : const Color(0xFF000000);
          
          RadioStation? playingStation;
          if (mediaItem != null) {
            playingStation = radioStations.firstWhere(
              (station) => station.streamUrl == mediaItem.id,
              orElse: () => radioStations.first
            );
          }
          
          // O Scaffold principal fica aqui para podermos usar o bottomNavigationBar
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
              backgroundColor: Colors.transparent, // Permite que o gradiente apareça
              body: SafeArea(
                // Removido o Padding. O StationListScreen lida com isso agora.
                child: MainScreen(audioHandler: widget.audioHandler),
              ),
              
              // Mini-Player (bottomNavigationBar)
              bottomNavigationBar: mediaItem != null && playingStation != null 
                  ? MiniPlayer(
                      audioHandler: widget.audioHandler,
                      mediaItem: mediaItem,
                      station: playingStation,
                      onTap: () {
                        // Navega para a tela cheia do player quando o mini-player é clicado
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => PlayerScreen(
                              audioHandler: widget.audioHandler,
                              mediaItem: mediaItem,
                              station: playingStation!,
                              onClose: () => Navigator.of(ctx).pop(), 
                            ),
                          ),
                        );
                      },
                    )
                  : null, // Não mostra o mini-player se não houver rádio tocando
            ),
          );
        },
      ),
    );
  }
}
