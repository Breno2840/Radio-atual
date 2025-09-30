import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audio_service/audio_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

// Imports dos seus arquivos de código
import 'models/radio_station.dart';
import 'widgets/audio_player_handler.dart';
import 'layout/app_layout.dart'; // <--- NOVO IMPORT

// Variável global para o handler
late AudioPlayerHandler _audioHandler; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light));

  if (Platform.isAndroid) {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      await Permission.notification.request();
    }
  }

  // LÓGICA DE CARREGAMENTO DA ÚLTIMA RÁDIO
  RadioStation? lastStation = await RadioStation.loadLastStation();
  final initialStation = lastStation ?? radioStations.first;
  
  // Inicializa o AudioService
  _audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.calculadora.my.channel.audio',
      androidNotificationChannelName: 'Reprodução de Áudio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  ) as AudioPlayerHandler;

  // Carrega os metadados da última rádio salva (ou a rádio padrão) no handler.
  await _audioHandler.setMediaItem(_audioHandler.createMediaItem(initialStation));

  runApp(MyApp(audioHandler: _audioHandler));
}

// MyApp agora é um simples StatelessWidget
class MyApp extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  const MyApp({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minha Rádio',
      theme: ThemeData.dark(),
      // O home agora aponta diretamente para o novo layout
      home: AppLayout(audioHandler: audioHandler),
    );
  }
}
