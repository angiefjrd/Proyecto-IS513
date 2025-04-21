import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../widgets/controller.dart';

class DetalleLibroPage extends StatefulWidget {
  final String libroId;

  const DetalleLibroPage({super.key, required this.libroId});

  @override
  State<DetalleLibroPage> createState() => _DetalleLibroPageState();
}

class _DetalleLibroPageState extends State<DetalleLibroPage> {
  final Controller controller = Get.find();
  final TextEditingController comentarioController = TextEditingController();

  @override
  void dispose() {
    comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final libro = controller.libros.firstWhere(
        (libro) => libro.id == widget.libroId,
        orElse: () => throw Exception('Libro no encontrado'),
      );

      return Scaffold(
        appBar: AppBar(
          title: Text(libro.titulo),
          actions: [
            IconButton(
              icon: const Icon(Icons.brush),
              onPressed: () => context.go('/arte/${libro.id}'),
              tooltip: 'Ver obras de arte',
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Portada y detalles
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                ),
                child: libro.portadaUrl.isNotEmpty
                    ? Image.network(
                        libro.portadaUrl,
                        fit: BoxFit.contain,
                      )
                    : const Icon(Icons.book, size: 100, color: Colors.white),
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
                    const SizedBox(height: 8),
                    Text(
                      'Por ${libro.autor}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber),
                        Text(' ${libro.calificacion.toStringAsFixed(1)}'),
                        const SizedBox(width: 20),
                        const Icon(Icons.people),
                        Text(' ${libro.lectores} lectores'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Descripción',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(libro.descripcion),
                    const SizedBox(height: 24),
                    const Text(
                      'Reacciones',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.thumb_up, size: 16),
                          label: const Text('Me gusta'),
                          onPressed: () => controller.agregarReaccion(
                              libro.id, 'me gusta'),
                          backgroundColor: libro.reacciones.contains('me gusta')
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.favorite, size: 16),
                          label: const Text('Fascinante'),
                          onPressed: () => controller.agregarReaccion(
                              libro.id, 'fascinante'),
                          backgroundColor:
                              libro.reacciones.contains('fascinante')
                                  ? Theme.of(context).primaryColor
                                  : null,
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.star, size: 16),
                          label: const Text('Increíble'),
                          onPressed: () => controller.agregarReaccion(
                              libro.id, 'increíble'),
                          backgroundColor: libro.reacciones.contains('increíble')
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Comentarios',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: comentarioController,
                            decoration: const InputDecoration(
                              hintText: 'Añade un comentario...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () {
                            if (comentarioController.text.isNotEmpty) {
                              controller.agregarComentario(
                                libro.id,
                                comentarioController.text,
                              );
                              comentarioController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.go('/agregar-arte/${libro.id}'),
          child: const Icon(Icons.brush),
        ),
      );
    });
  }
}
