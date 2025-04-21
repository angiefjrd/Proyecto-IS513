import 'package:flutter/material.dart';
import '../models/arte.dart';

class Galeria extends StatelessWidget {
  final Arte arte;

  const Galeria({super.key, required this.arte});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          arte.imagenUrl.isNotEmpty
              ? Image.network(
                  arte.imagenUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50),
                ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  arte.titulo,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Artista: ${arte.artista}'),
                const SizedBox(height: 8),
                Text(arte.descripcion),
              ],
            ),
          ),
        ],
      ),
    );
  }
}