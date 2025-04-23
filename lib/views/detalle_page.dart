import 'package:flutter/material.dart';
import 'package:writerhub/models/libro.dart';

class BookDetailPage extends StatelessWidget {
  final Libro libro;

  const BookDetailPage({super.key, required this.libro});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(libro.titulo),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada del libro
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: libro.portadaUrl.isNotEmpty
                    ? Image.network(
                        libro.portadaUrl,
                        height: 250,
                        width: 170,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 250,
                        width: 170,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.book, size: 60),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Título y autor
            Text(
              libro.titulo,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Autor: ${libro.autor}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 16),

            // Géneros
            if (libro.genres.isNotEmpty)
              Wrap(
                spacing: 8,
                children: libro.genres.map((genre) {
                  return Chip(
                    label: Text(genre),
                    backgroundColor: Colors.purple.shade100,
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),

            // Descripción
            const Text(
              'Descripción',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(libro.descripcion),

            const SizedBox(height: 20),

            // Fecha de creación
            Text(
              'Creado el: ${libro.fechaCreacion}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Botón de volver
            Center(
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Volver"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

