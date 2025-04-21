import 'package:flutter/material.dart';

class CLibro extends StatelessWidget {
  final String comentario;

  const CLibro({
    super.key,
    required this.comentario,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con avatar y nombre
            Row(
              children: [
                const CircleAvatar(
                  radius: 14,
                  child: Icon(Icons.person, size: 14),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Usuario anónimo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  'Hoy',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Cuerpo del comentario
            Text(
              comentario,
              style: const TextStyle(fontSize: 14),
            ),
            
            // Acciones (opcional)
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up, size: 16),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.reply, size: 16),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}