// lib/pages/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import '../layout/app_layout.dart';
import '../widgets/audio_player_handler.dart'; // Import necessário

class SplashScreen extends StatefulWidget {
  final AudioPlayerHandler audioHandler;

  const SplashScreen({super.key, required this.audioHandler});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Usa SchedulerBinding para garantir que a navegação ocorra após a construção
    // da primeira tela e evitar erros de navegação.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _startApp();
    });
  }

  void _startApp() async {
    // 1. Você pode adicionar um atraso mínimo para garantir que a tela apareça.
    // O seu main.dart já está fazendo o carregamento pesado, então um pequeno
    // delay visual pode ser suficiente.
    await Future.delayed(const Duration(seconds: 2));

    // 2. Navega para a tela principal (AppLayout)
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AppLayout(audioHandler: widget.audioHandler),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definindo o System UI (Barras) para um estilo que combine com a splash
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // Ícones claros
      systemNavigationBarIconBrightness: Brightness.light, // Ícones claros
    ));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // GRADIENTE BONITO
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D47A1), // Azul escuro
              Color(0xFF00C853), // Verde vibrante (cor de rádio/onda)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone ou Logo da Rádio
              const Icon(
                Icons.radio,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              // Título
              Text(
                'Minha Rádio',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
