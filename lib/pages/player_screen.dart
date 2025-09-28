// lib/pages/player_screen.dart (Tela Cheia)
import 'package:flutter/material.dart';
// ... (imports)

class PlayerScreen extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  final MediaItem? mediaItem; 
  final RadioStation station; 
  final VoidCallback onClose; // NOVA PROPRIEDADE para fechar a tela

  const PlayerScreen({
    super.key,
    required this.audioHandler,
    required this.mediaItem,
    required this.station, 
    required this.onClose, // AGORA É 'onClose'
  });

  @override
  Widget build(BuildContext context) {
    // ... (lógica de títulos permanece igual)
    final artUri = mediaItem?.artUri ?? Uri.parse(station.artUrl); 
    final String actualTitle = mediaItem?.title ?? station.name;
    final bool hasSongTitle = actualTitle != station.name;
    final String displayTitle = hasSongTitle ? actualTitle : '${station.name} ${station.frequency}';
    final String displaySubtitle = hasSongTitle ? station.name : station.location;
    
    return Column(
      children: [
        // NOVO: Botão de Fechar para voltar para a lista
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
            onPressed: onClose, // Chama o Navigator.pop() definido no main.dart
          ),
        ),
        
        Expanded(
          // ... (o restante da UI do player permanece igual)
