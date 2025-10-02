// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audio_service/audio_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

import 'models/radio_station.dart';
import 'widgets/audio_player_handler.dart';
import 'layout/app_layout.dart';

late AudioPlayerHandler _audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  if (Platform.isAndroid) {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      await Permission.notification.request();
    }
  }

  // ✅ Carrega a lista de rádios ANTES de iniciar o app
  final radioStationsFuture = fetchRadioStations();

  runApp(MyApp(
    audioHandlerFuture: _initAudioHandler(radioStationsFuture),
    radioStationsFuture: radioStationsFuture,
  ));
}

Future<AudioPlayerHandler> _initAudioHandler(Future<List<RadioStation>> radioStationsFuture) async {
  final radioStations = await radioStationsFuture;
  final lastStation = await RadioStation.loadLastStation();
  final initialStation = lastStation ?? radioStations.first;

  _audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.calculadora.my.channel.audio',
      androidNotificationChannelName: 'Reprodução de Áudio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  ) as AudioPlayerHandler;

  await _audioHandler.loadStation(initialStation);
  return _audioHandler;
}

class MyApp extends StatelessWidget {
  final Future<AudioPlayerHandler> audioHandlerFuture;
  final Future<List<RadioStation>> radioStationsFuture;

  const MyApp({
    super.key,
    required this.audioHandlerFuture,
    required this.radioStationsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minha Rádio',
      theme: ThemeData.dark(),
      home: FutureBuilder<AudioPlayerHandler>(
        future: audioHandlerFuture,
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
                child: Text('Erro: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
              ),
            );
          }
          return AppLayout(
            audioHandler: snapshot.data!,
            radioStationsFuture: radioStationsFuture,
          );
        },
      ),
    );
  }
}