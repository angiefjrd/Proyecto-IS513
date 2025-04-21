import 'package:flutter/material.dart';
import '../models/comentarios.dart';

class CLibro extends StatelessWidget {
  final CLibro comentario;
  final void Function()? onTap;

  const CLibro({
    super.key,
    required this.comentario,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con avatar y nombre
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
                    comentario.fechaFormateada(),
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
                comentario.texto,
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
      ),
    );
  }
}