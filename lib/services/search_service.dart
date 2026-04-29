import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchService {
  // Usamos "static" para não precisar criar um objeto complexo.
  // Basta chamar SearchService.buscar(...)
  static Future<List<dynamic>> buscar(String query) async {
    final url = Uri.parse('https://photon.komoot.io/api/?q=$query&limit=5');

    final response = await http.get(
      url,
      headers: {'User-Agent': 'AcessMap/1.0'},
    );

    if (response.statusCode == 200) {
      return json.decode(
        response.body,
      )['features']; // O trabalhador devolve a lista
    }
    return []; // Se der erro, devolve lista vazia
  }
}
