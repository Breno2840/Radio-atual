import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audio_service/audio_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart'; // Importante para debugPrint

// Imports dos seus arquivos de código
import 'models/radio_station.dart';
import 'widgets/audio_player_handler.dart';
import 'layout/app_layout.dart';

// Variável global para o handler
late AudioPlayerHandler _audioHandler;

Future<void> main() async {
  // Bloco try-catch para pegar QUALQUER erro durante a inicialização
  try {
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

    // --- LÓGICA DE CARREGAMENTO SEGURA ---
    debugPrint("Iniciando carregamento das estações...");
    RadioStation? lastStation = await RadioStation.loadLastStation();
    List<RadioStation> stations = await RadioStation.fetchStations();
    debugPrint("Estações carregadas. Quantidade: ${stations.length}");

    RadioStation? initialStation;
    if (lastStation != null) {
      initialStation = lastStation;
      debugPrint("Usando a última estação salva: ${initialStation.name}");
    } else if (stations.isNotEmpty) {
      // SÓ PEGA O PRIMEIRO SE A LISTA NÃO ESTIVER VAZIA
      initialStation = stations.first;
      debugPrint("Usando a primeira estação da lista: ${initialStation.name}");
    } else {
      // A lista veio vazia e não há estação salva
      debugPrint("ERRO CRÍTICO: Nenhuma estação salva e a lista da internet veio vazia.");
      // Aqui você poderia definir uma estação "padrão" ou de erro se quisesse
      // Por enquanto, vamos deixar `initialStation` nulo para ver o comportamento
    }
    // --- FIM DA LÓGICA DE CARREGAMENTO SEGURA ---

    debugPrint("Inicializando o AudioService...");
    _audioHandler = await AudioService.init(
      builder: () => AudioPlayerHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.calculadora.my.channel.audio',
        androidNotificationChannelName: 'Reprodução de Áudio',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    ) as AudioPlayerHandler;
    debugPrint("AudioService inicializado com sucesso.");

    // Garante que só vamos carregar uma estação se ela existir
    if (initialStation != null) {
      await _audioHandler.loadStation(initialStation);
      debugPrint("Estação inicial carregada no handler.");
    } else {
      // Se não houver estação inicial, talvez o AppLayout precise saber disso
      // ou você pode carregar uma estação "fantasma"/padrão
      debugPrint("Nenhuma estação inicial para carregar no handler.");
    }
    
    runApp(MyApp(audioHandler: _audioHandler));

  } catch (e, stacktrace) {
    // ESTE É O PONTO MAIS IMPORTANTE
    // Se o app der tela preta, o erro aparecerá aqui no console.
    debugPrint('####################################################');
    debugPrint('###### ERRO FATAL DURANTE A INICIALIZAÇÃO (main) #####');
    debugPrint('####################################################');
    debugPrint('ERRO: $e');
    debugPrint('STACKTRACE: $stacktrace');
    debugPrint('####################################################');
  }
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
