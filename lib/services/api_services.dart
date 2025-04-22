import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:writerhub/models/libro.dart';

class ApiService {
  Future<List<Libro>> fetchBooks({String query = 'fiction'}) async {
    try {
      final url = 'https://www.googleapis.com/books/v1/volumes?q=$query&maxResults=30';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List items = data['items'] ?? [];

        return items.map((item) {
          final volumeInfo = item['volumeInfo'] ?? {};
          final accessInfo = item['accessInfo'] ?? {};

          return Libro(
            id: item['id']?.toString() ?? 'no-id',
            titulo: volumeInfo['title']?.toString() ?? 'Título desconocido',
            autor: (volumeInfo['authors'] as List?)?.join(', ') ?? 'Autor desconocido',
            descripcion: volumeInfo['description']?.toString() ?? 'Sin descripción',
            portadaUrl: volumeInfo['imageLinks']?['thumbnail']?.toString() ?? '',
            calificacion: (volumeInfo['averageRating'] as num?)?.toDouble() ?? 0.0,
            lectores: 0, 
            reacciones: [], 
            fechaCreacion: DateTime.now(), 
            autorId: 'google-books', 
          );
        }).toList();
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cargar libros: $e');
    }
  }
}