import 'package:flutter/material.dart';
import 'package:writerhub/models/libro.dart';

class DLibro extends StatelessWidget {
  final Libro libro;
  final void Function() onTap;

  const DLibro({
    super.key,
    required this.libro,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Portada del libro (¡sin ClipRRect ni PhysicalModel!)
              Container(
                width: 80,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: libro.portadaUrl.isNotEmpty
                    ? Image.network(
                        libro.portadaUrl,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.book, size: 40),
              ),
              const SizedBox(width: 16),
              // Detalles del libro
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      libro.titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      libro.autor,
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}