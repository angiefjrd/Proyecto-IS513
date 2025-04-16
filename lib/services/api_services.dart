import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  Future<List<Book>> fetchBooks({String query = 'flutter'}) async {
    final response = await http.get(Uri.parse('$_baseUrl?q=$query&maxResults=50'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List items = data['items'] ?? [];
      return items.map((item) => Book.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar libros');
    }
  }
}
