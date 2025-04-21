import 'package:flutter/material.dart';
import 'package:writerhub/models/comentarios.dart';

class Comentariolib extends StatelessWidget {
  final Comentario comentario;

  const Comentariolib({super.key, required this.comentario});

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
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundImage: comentario.avatarUrl.isNotEmpty 
                      ? NetworkImage(comentario.avatarUrl) 
                      : null,
                  child: comentario.avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 14)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  comentario.autor,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatearFecha(comentario.fecha),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comentario.texto,
              style: const TextStyle(fontSize: 14),
            ),
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

  String _formatearFecha(DateTime fecha) {
    final now = DateTime.now();
    final difference = now.difference(fecha);

    if (difference.inMinutes < 1) return 'Ahora mismo';
    if (difference.inHours < 1) return 'Hace ${difference.inMinutes} min';
    if (difference.inDays < 1) return 'Hace ${difference.inHours} h';
    if (difference.inDays < 7) return 'Hace ${difference.inDays} días';

    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}