import 'package:flutter/material.dart';
import 'package:writerhub/models/libro.dart'; 

class DetailPage extends StatelessWidget {
  final Libro book;

  const DetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.titulo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            book.portadaUrl.isNotEmpty
                ? Image.network(book.portadaUrl)
                : const Placeholder(fallbackHeight: 150),
            const SizedBox(height: 10),
            Text(
              book.titulo,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'by ${book.autor}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              book.descripcion,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
