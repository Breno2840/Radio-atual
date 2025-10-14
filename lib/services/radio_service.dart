import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/radio_station.dart';

class RadioService {
  // A URL que você forneceu para o seu JSON de rádios.
  static const String _jsonUrl = 'https://late-tree-7ba3.mandy2a2839.workers.dev/';

  // Função que busca, decodifica e retorna a lista de estações de rádio.
  Future<List<RadioStation>> fetchRadioStations() async {
    try {
      final response = await http.get(Uri.parse(_jsonUrl));

      if (response.statusCode == 200) {
        // Se o servidor retornar uma resposta OK, decodificamos o JSON.
        // O corpo da resposta é uma String, então usamos utf8.decode para garantir
        // o suporte a caracteres especiais (acentos, etc.).
        final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
        
        // Mapeamos a lista de JSONs para uma lista de objetos RadioStation.
        return jsonData.map((jsonItem) => RadioStation.fromJson(jsonItem)).toList();
      } else {
        // Se a resposta não for OK, lançamos um erro.
        throw Exception('Falha ao carregar a lista de rádios. Código: ${response.statusCode}');
      }
    } catch (e) {
      // Em caso de qualquer outro erro (ex: sem conexão), lançamos uma exceção.
      throw Exception('Falha ao conectar ao servidor: $e');
    }
  }
}
