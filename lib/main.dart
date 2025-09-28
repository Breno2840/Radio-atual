// lib/main.dart (Final)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audio_service/audio_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:device_info_plus/device_info_plus.dart';

// Importando os novos e velhos arquivos:
import 'pages/player_screen.dart';
import 'pages/station_list_screen.dart';
import 'pages/main_screen.dart'; // NOVO IMPORT
import 'models/radio_station.dart';
import 'widgets/audio_player_handler.dart';

// ... (main function permanece a mesma)

Future<void> main() async {
  // ... (código de inicialização e permissão)
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // ... (System UI settings)
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
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: StreamBuilder<MediaItem?>(
          stream: widget.audioHandler.mediaItem,
          builder: (context, snapshot) {
            final mediaItem = snapshot.data;
            final artUri = mediaItem?.artUri;
            
            // Lógica de mudança de cor mantida aqui (pois afeta o container global do app)
            if (artUri != null && artUri != _lastArtUri) {
              _lastArtUri = artUri;
              _updateBackgroundColors(artUri);
            }
            
            final startColor = mediaItem != null ? _startColor : const Color(0xFF1D244D);
            final endColor = mediaItem != null ? _endColor : const Color(0xFF000000);
            
            // O MyApp agora só cuida do tema e do fundo, e passa o controle para o MainScreen.
            return AnimatedContainer(
              duration: const Duration(seconds: 1),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [startColor, endColor]
                )
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox.expand(
                    // NOVO: Chama o MainScreen para gerenciar a navegação entre telas
                    child: MainScreen(audioHandler: widget.audioHandler), 
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
