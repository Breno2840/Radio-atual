// lib/models/radio_station.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
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

  static const String _lastStationKey = 'last_radio_station';

  Map<String, dynamic> toJson() => {
        'name': name,
        'frequency': frequency,
        'band': band,
        'location': location,
        'streamUrl': streamUrl,
        'artUrl': artUrl,
      };

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

  static Future<void> saveStation(RadioStation station) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastStationKey, json.encode(station.toJson()));
  }

  static Future<RadioStation?> loadLastStation() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_lastStationKey);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        return RadioStation.fromJson(jsonMap);
      } catch (e) {
        await prefs.remove(_lastStationKey);
        return null;
      }
    }
    return null;
  }
}

// 🔥 Nova função: busca a lista de rádios de um JSON online
Future<List<RadioStation>> fetchRadioStations() async {
  // 🔗 Substitua esta URL pela URL RAW do seu Gist
  final url = Uri.parse('https://gist.githubusercontent.com/seuusuario/seu-gist-id/raw/radios.json');

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((e) => RadioStation.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Falha ao carregar: status ${response.statusCode}');
    }
  } catch (e) {
    // Em vez de fallback, vamos lançar o erro para exibir tela de "sem conexão"
    throw Exception('Sem conexão com a internet ou erro no servidor');
  }
}