import 'dart:convert';
import 'package:flutter/foundation.dart'; // Importe para usar o debugPrint
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

  // Converte a instância em um Map<String, dynamic>
  Map<String, dynamic> toJson() => {
        'name': name,
        'frequency': frequency,
        'band': band,
        'location': location,
        'streamUrl': streamUrl,
        'artUrl': artUrl,
      };

  // --- MÉTODO fromJson ATUALIZADO E MAIS SEGURO ---
  // Evita erros se algum campo for nulo ou de tipo diferente no JSON
  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      name: json['name']?.toString() ?? 'Rádio sem nome',
      frequency: json['frequency']?.toString() ?? '',
      band: json['band']?.toString() ?? 'FM',
      location: json['location']?.toString() ?? 'Local não informado',
      streamUrl: json['streamUrl']?.toString() ?? '',
      artUrl: json['artUrl']?.toString() ?? '',
    );
  }

  // --- MÉTODO fetchStations ATUALIZADO COM LOG DE ERRO DETALHADO ---
  static Future<List<RadioStation>> fetchStations() async {
    try {
      final response = await http.get(Uri.parse('https://late-tree-7ba3.mandy2a2839.workers.dev/'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => RadioStation.fromJson(json)).toList();
      } else {
        // Log para erros de resposta do servidor (404, 500, etc.)
        debugPrint('--- ERRO DE REDE AO BUSCAR ESTAÇÕES ---');
        debugPrint('STATUS CODE: ${response.statusCode}');
        debugPrint('RESPOSTA DO SERVIDOR: ${response.body}');
        debugPrint('---------------------------------------');
        throw Exception('Falha ao carregar estações: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      // Log para qualquer outro erro (parsing do JSON, sem internet, etc.)
      debugPrint('--- ERRO DETALHADO AO PROCESSAR ESTAÇÕES ---');
      debugPrint('ERRO: $e');
      debugPrint('ONDE ACONTECEU (STACKTRACE): $stacktrace');
      debugPrint('--------------------------------------------');
      throw Exception('Erro ao buscar estações: $e');
    }
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
