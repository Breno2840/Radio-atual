// lib/models/radio_station.dart
import 'dart:convert';
import 'dart:io';
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

Future<List<RadioStation>> fetchRadioStations() async {
  final url = Uri.parse('https://gist.githubusercontent.com/Breno2840/d66d95ef976ae84ff5de3d2cb9631036/raw/radios.json');

  try {
    // Cria um cliente HTTP com timeout
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10)
      ..idleTimeout = const Duration(seconds: 10);

    final request = await client.getUrl(url);
    final response = await request.close();

    if (response.statusCode == 200) {
      final jsonString = await response.transform(const Utf8Decoder()).join();
      final List<dynamic> jsonList = json.decode(jsonString);
      client.close();
      return jsonList.map((e) => RadioStation.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      client.close();
      throw Exception('HTTP ${response.statusCode}');
    }
  } catch (e) {
    print('⚠️ Falha ao carregar do Gist: $e');
    // Fallback local com 1 rádio real (ex: Jovem Pan)
    return [
      const RadioStation(
        name: 'Rádio Jovem Pan',
        frequency: '100.9',
        band: 'FM',
        location: 'São Paulo, SP',
        streamUrl: 'https://stream.zeno.fm/c45wbq2us3buv',
        artUrl: 'https://425w010y9m.ucarecd.net/9f5576a9-38da-48b4-9fab-67b09984ae0b/-/preview/1000x1000/',
      ),
    ];
  }
}