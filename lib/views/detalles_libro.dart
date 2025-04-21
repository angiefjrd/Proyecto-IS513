import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/controller.dart';
import '../views/clibros.dart';

class DetallesLibro extends StatelessWidget {
  final String idLibro;

  const DetallesLibro({super.key, required this.idLibro});

  @override
  Widget build(BuildContext context) {
    final Controller controlador = Get.find();
    final libro = controlador.libros.firstWhere((libro) => libro.id == idLibro);
    final TextEditingController controladorComentario = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(libro.titulo),
        actions: [
          IconButton(
            icon: const Icon(Icons.brush),
            onPressed: () => context.go('/obra-arte/${libro.id}'),
            tooltip: 'Ver obras de arte',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              libro.portadaUrl,
              height: 300,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.book, size: 100),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    libro.titulo,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'Autor: ${libro.autor}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      Text(' ${libro.calificacion}'),
                      const SizedBox(width: 20),
                      const Icon(Icons.people),
                      Text(' ${libro.lectores} lectores'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(libro.descripcion),
                  const SizedBox(height: 24),
                  const Text(
                    'Comentarios',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...libro.comentarios.map((comentario) => 
                    CLibro(comentario: comentario)
                  ).toList(),
                  TextField(
                    controller: controladorComentario,
                    decoration: InputDecoration(
                      labelText: 'Añade tu comentario',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (controladorComentario.text.isNotEmpty) {
                            controlador.agregarComentario(
                              libro.id, 
                              controladorComentario.text
                            );
                            controladorComentario.clear();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}