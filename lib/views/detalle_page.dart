import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/libro.dart';

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

  @override
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
            // Portada
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

            // Fecha
            Text(
              'Creado el: ${widget.libro.fechaCreacion}',
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // Botón agregar capítulo (solo si es el autor)
            if (isAuthor)
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Agregar Capítulo"),
                  onPressed: () {
                    final siguienteNumero = (widget.libro.capitulos?.length ?? 0) + 1;
                    Navigator.pushNamed(
                      context,
                      '/crear-capitulo/${widget.libro.id}/$siguienteNumero',
                      arguments: {
                        'tituloLibro': widget.libro.titulo,
                      },
                    );
                  },
                ),
              ),

            const SizedBox(height: 10),

            // Botón para guardar el libro
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await guardarLibroEnBiblioteca(widget.libro);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Libro guardado en tu biblioteca')),
                  );
                },
                icon: const Icon(Icons.bookmark),
                label: const Text('Guardar libro'),
              ),
            ),

            const SizedBox(height: 10),

            // Botón volver
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

Future<void> guardarLibroEnBiblioteca(Libro libro) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final docRef = FirebaseFirestore.instance
      .collection('usuarios')
      .doc(user.uid)
      .collection('biblioteca')
      .doc(libro.id);

  await docRef.set({
    'libroId': libro.id,
    'titulo': libro.titulo,
    'portadaUrl': libro.portadaUrl,
    'autor': libro.autor,
    'fechaGuardado': Timestamp.now(),
  });
}
