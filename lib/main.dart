import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audio_service/audio_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:collection/collection.dart';

import 'models/radio_station.dart';
import 'widgets/audio_player_handler.dart'; 
import 'layout/app_layout.dart'; 

late AudioPlayerHandler _audioHandler; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 ========== INICIANDO APP ==========');
  
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light));

  if (Platform.isAndroid) {
    print('📱 Solicitando permissões Android...');
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('📱 SDK Android: ${androidInfo.version.sdkInt}');
    
    if (androidInfo.version.sdkInt >= 33) {
      final status = await Permission.notification.request();
      print('🔔 Permissão de notificação: $status');
    }
  }

  print('💾 Carregando última rádio salva...');
  RadioStation? lastStation = await RadioStation.loadLastStation();
  if (lastStation != null) {
    print('✅ Última rádio: ${lastStation.name}');
  } else {
    print('⚠️ Nenhuma rádio salva');
  }

  List<RadioStation> stations = [];
  try {
    print('🌐 Buscando estações online...');
    stations = await RadioStation.fetchStations();
    print('✅ ${stations.length} estações carregadas');
  } catch (e) {
    print("❌ Erro ao carregar estações online: $e");
  }

  final initialStation = lastStation ?? stations.firstOrNull ?? const RadioStation(
    name: 'Rádio Padrão',
    frequency: '00.0',
    band: 'FM',
    location: 'Localidade Padrão',
    streamUrl: 'https://exemplo.com/radio.mp3',
    artUrl: 'https://exemplo.com/arte.jpg',
  );
  print('📻 Estação inicial: ${initialStation.name}');

  try {
    print('🎵 Inicializando AudioService...');
    
    _audioHandler = await AudioService.init(
      builder: () {
        print('🏗️ Criando AudioPlayerHandler...');
        return AudioPlayerHandler();
      },
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.calculadora.my.channel.audio',
        androidNotificationChannelName: 'Reprodução de Áudio',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    ) as AudioPlayerHandler;
    
    print('✅ AudioService inicializado com sucesso!');
    print('✅ AudioHandler criado: ${_audioHandler.runtimeType}');

    print('📥 Carregando estação inicial...');
    await _audioHandler.loadStation(initialStation);
    print('✅ Estação inicial carregada!');
    
  } catch (e, stackTrace) {
    print("❌❌❌ ERRO CRÍTICO ao inicializar AudioService ❌❌❌");
    print("Erro: $e");
    print("StackTrace: $stackTrace");
    
    // ✅ CORREÇÃO: Mostra mensagem genérica sem expor URLs
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 30),
                const Text(
                  'Erro ao inicializar o player',
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.white
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                const Text(
                  'Ocorreu um problema ao inicializar o reprodutor de áudio. Tente reiniciar o aplicativo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Fechar App'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
    return;
  }

  print('🎉 App iniciado com sucesso!');
  print('🚀 ========== INICIANDO UI ==========\n');
  
  runApp(MyApp(audioHandler: _audioHandler));
}

class MyApp extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  const MyApp({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minha Rádio',
      theme: ThemeData.dark(),
      home: AppLayout(audioHandler: audioHandler),
    );
  }
}