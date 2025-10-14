import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RadioStation {
  final String name;
  final String frequency;
  final String band;
  final String location;
  final String streamUrl;
  final String artUrl;

  const RadioStation({
    required this.name,
    required this.frequency,
    required this.band,
    required this.location,
    required this.streamUrl,
    required this.artUrl,
  });

  // Chave para SharedPreferences
  static const String _lastStationKey = 'last_radio_station';

  // Converte a instância em um Map<String, dynamic>
  Map<String, dynamic> toJson() => {
        'name': name,
        'frequency': frequency,
        'band': band,
        'location': location,
        'streamUrl': streamUrl,
        'artUrl': artUrl,
      };

  // Cria uma instância a partir de um Map<String, dynamic>
  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      name: json['name'] as String,
      frequency: json['frequency'] as String,
      band: json['band'] as String,
      location: json['location'] as String,
      streamUrl: json['streamUrl'] as String,
      artUrl: json['artUrl'] as String,
    );
  }

  // Salva a estação de rádio atual no SharedPreferences
  static Future<void> saveStation(RadioStation station) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastStationKey, json.encode(station.toJson()));
  }

  // Carrega a última estação de rádio salva, ou retorna null se não houver
  static Future<RadioStation?> loadLastStation() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_lastStationKey);

    if (jsonString != null) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        return RadioStation.fromJson(jsonMap);
      } catch (e) {
        // Em caso de erro ao decodificar (dados corrompidos, etc.), retorna null
        await prefs.remove(_lastStationKey);
        return null;
      }
    }
    return null;
  }
}

// >>> A LISTA DE RÁDIOS QUE ESTAVA AQUI FOI REMOVIDA <<<
