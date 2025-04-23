import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:writerhub/models/libro.dart';

class BookDetailPage extends StatefulWidget {
  final Libro libro;

  const BookDetailPage({super.key, required this.libro});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late final String? _currentUserId;
  @override
   void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  bool get isAuthor => _currentUserId == widget.libro.autorId;
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.libro.titulo),
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
                child: widget.libro.portadaUrl.isNotEmpty
                    ? Image.network(
                        widget.libro.portadaUrl,
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
              widget.libro.titulo,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Autor: ${widget.libro.autor}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 16),

            // Géneros
            if (widget.libro.genres.isNotEmpty)
              Wrap(
                spacing: 8,
                children: widget.libro.genres.map((genre) {
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
            Text(widget.libro.descripcion),

            const SizedBox(height: 20),

            // Fecha de creación
            Text(
              'Creado el: ${widget.libro.fechaCreacion}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (isAuthor)
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Agregar Capítulo"),
                onPressed: () {
                  Navigator.pushNamed(
                  context,
                  '/crear-capitulo/${widget.libro.id}/${widget.libro.capitulos!.length + 1}', 
                  arguments: {
                    'tituloLibro': widget.libro.titulo,
                    },
                  );
                },
              ),
            ),
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

