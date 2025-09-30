// lib/main.dart

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'widgets/audio_player_handler.dart';
import 'pages/main_page.dart';
import 'models/radio_station.dart';

// Variável global para armazenar o handler
late AudioPlayerHandler _audioHandler;

// Função principal que configura o AudioService
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Define o estilo da barra de status (topo)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, 
    statusBarIconBrightness: Brightness.light, 
  ));

  // Inicializa o AudioService
  _audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationInfo: AndroidNotificationInfo(
        channelId: 'radio_channel',
        channelName: 'Rádio Player',
        notificationColor: 0xFF2C2C2E,
        enableForegroundService: true,
      ),
      androidStopForegroundOnPause: true, 
      fastAudioFocusResolution: true,
    ),
  );

  // --- LÓGICA DE CARREGAMENTO DA ÚLTIMA RÁDIO ---
  final lastUrl = await RadioStation.getLastPlayedUrl();
  RadioStation stationToLoad;

  if (lastUrl != null) {
    // Tenta encontrar a rádio salva. Se não encontrar, usa a primeira (Jovem Pan)
    stationToLoad = RadioStation.findStationByUrl(lastUrl) ?? radioStations.first;
  } else {
    // Se não houver nenhuma rádio salva, usa a primeira da lista (Jovem Pan)
    stationToLoad = radioStations.first;
  }
  
  // Carrega a MediaItem no handler, mas NÃO toca automaticamente.
  // Criamos uma nova instância do handler apenas para usar o método createMediaItem.
  await _audioHandler.setMediaItem(AudioPlayerHandler().createMediaItem(stationToLoad));
  // -----------------------------------------------------

  runApp(const RadioApp());
}

class RadioApp extends StatelessWidget {
  const RadioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Seu App de Rádio',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF2C2C2E),
        scaffoldBackgroundColor: const Color(0xFF1C1C1E),
        cardColor: const Color(0xFF2C2C2E),
        fontFamily: 'Roboto',
      ),
      home: MainPage(audioHandler: _audioHandler),
    );
  }
}
