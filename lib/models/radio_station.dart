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

  // Chave para SharedPreferences
  static const String _lastStationKey = 'last_radio_station';
  static const String _stationsCacheKey = 'cached_radio_stations';

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

  // Método para carregar estações do JSON online
  static Future<List<RadioStation>> fetchStations() async {
    try {
      final response = await http.get(Uri.parse('https://late-tree-7ba3.mandy2a2839.workers.dev/'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        final List<dynamic> jsonList = jsonMap['radios'] as List<dynamic>;
        final List<RadioStation> stations = jsonList.map((json) => RadioStation.fromJson(json)).toList();

        // Salva as estações localmente
        await _saveStationsToCache(stations);

        return stations;
      } else {
        throw Exception('Falha ao carregar estações: ${response.statusCode}');
      }
    } catch (e) {
      // Se falhar, tenta carregar do cache
      final cached = await _loadStationsFromCache();
      if (cached.isNotEmpty) {
        return cached;
      } else {
        throw Exception('Erro ao buscar estações e sem cache: $e');
      }
    }
  }

  // Salva estações no cache local
  static Future<void> _saveStationsToCache(List<RadioStation> stations) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = stations.map((station) => station.toJson()).toList();
    await prefs.setString(_stationsCacheKey, json.encode(jsonList));
  }

  // Carrega estações do cache local
  static Future<List<RadioStation>> _loadStationsFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_stationsCacheKey);

    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => RadioStation.fromJson(json)).toList();
      } catch (e) {
        // Se der erro ao decodificar, limpa o cache
        await prefs.remove(_stationsCacheKey);
        return [];
      }
    }
    return [];
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