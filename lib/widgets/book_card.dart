import 'package:flutter/material.dart';
import 'package:writerhub/models/libro.dart';
import '../views/detalle_page.dart';

class LibroCard extends StatelessWidget {
  final Libro book;

  const LibroCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailPage(book: book)),
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPortada(),
            _buildTitulo(),
            _buildAutor(),
          ],
        ),
      ),
    );
  }

  Widget _buildPortada() {
    final hasPortada = book.portadaUrl?.isNotEmpty ?? false;
    
    return Container(
      height: 150,
      width: double.infinity,
      child: hasPortada
          ? Image.network(
              book.portadaUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(Icons.image, size: 50, color: Colors.grey),
    );
  }

  Widget _buildTitulo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        book.titulo ?? 'Título no disponible',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  Widget _buildAutor() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        'by ${book.autor ?? 'Autor desconocido'}',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}