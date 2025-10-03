// lib/pages/player_screen.dart
import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/audio_player_handler.dart';

class PlayerScreen extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  final MediaItem? mediaItem;
  final VoidCallback onShowList;

  const PlayerScreen({
    super.key,
    required this.audioHandler,
    required this.mediaItem,
    required this.onShowList,
  });

  @override
  Widget build(BuildContext context) {
    final name = mediaItem?.title ?? 'Rádio';
    final location = mediaItem?.artist ?? 'Transmissão ao vivo';
    final artUrl = mediaItem?.artUri;

    return Column(
      children: [
        // Cabeçalho
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: onShowList,
            ),
            const Text(
              'Reproduzindo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(width: 40), // Espaço para alinhar com o ícone de voltar
          ],
        ),
        const SizedBox(height: 30),

        // Capa da rádio
        if (artUrl != null)
          CachedNetworkImage(
            imageUrl: artUrl.toString(),
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
            errorWidget: (context, url, error) => const Icon(Icons.radio, size: 100, color: Colors.grey),
          )
        else
          const Icon(Icons.radio, size: 100, color: Colors.white),

        const SizedBox(height: 20),

        // Nome da rádio
        Text(
          name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
        ),

        // Localização
        Text(
          location,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // Controles
        StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, snapshot) {
            final playbackState = snapshot.data;
            final isPlaying = playbackState?.playing ?? false;

            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botão de parar
                IconButton(
                  icon: const Icon(Icons.stop, color: Colors.white, size: 40),
                  onPressed: audioHandler.stop,
                ),
                const SizedBox(width: 20),
                // Botão de play/pause
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                  onPressed: isPlaying ? audioHandler.pause : audioHandler.play,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}