import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:writerhub/models/libro.dart';

class ApiService {
  Future<List<Libro>> fetchBooks({String query = 'fiction'}) async {
    final url =
        'https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=30';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List items = data['items'] ?? [];

      return items.map((item) => Libro.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar libros');
    }
  }
}
