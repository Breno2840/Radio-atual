// lib/widgets/radio_grid_item.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
// Importa o modelo
import '../models/radio_station.dart'; 

class RadioGridItem extends StatelessWidget {
  final RadioStation station;
  final VoidCallback onTap;

  const RadioGridItem({
    super.key,
    required this.station,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color(0xFF2C2C2E),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: station.artUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.black26),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.radio, color: Colors.white54, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${station.name} ${station.frequency}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    station.location,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
