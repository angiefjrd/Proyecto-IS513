import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:writerhub/views/galeria_page.dart'; // Asegúrate de tener esta importación
import '../widgets/controller.dart';
import '../models/arte.dart';

class ArtePantalla extends StatelessWidget {
  final String libroId;

  const ArtePantalla({super.key, required this.libroId});

  @override
  Widget build(BuildContext context) {
    final Controller controlador = Get.find();
    final libro = controlador.libros.firstWhere((b) => b.id == libroId);
    final List<Arte> artesDelLibro = controlador.obrasArte.where((a) => a.libroId == libroId).toList();

    final TextEditingController tituloController = TextEditingController();
    final TextEditingController artistaController = TextEditingController();
    final TextEditingController descripcionController = TextEditingController();
    final TextEditingController imagenUrlController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Arte de ${libro.titulo}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Formulario para añadir arte
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Añade arte inspirado en este libro',
                    style: TextStyle(fontSize: 18),
                  ),
                  TextField(
                    controller: tituloController,
                    decoration: const InputDecoration(labelText: 'Título del arte'),
                  ),
                  TextField(
                    controller: artistaController,
                    decoration: const InputDecoration(labelText: 'Tu nombre'),
                  ),
                  TextField(
                    controller: descripcionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                    maxLines: 3,
                  ),
                  TextField(
                    controller: imagenUrlController,
                    decoration: const InputDecoration(labelText: 'URL de la imagen'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (tituloController.text.isNotEmpty &&
                          artistaController.text.isNotEmpty &&
                          imagenUrlController.text.isNotEmpty) {
                        final nuevaObra = Arte(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          libroId: libroId,
                          titulo: tituloController.text,
                          artista: artistaController.text,
                          descripcion: descripcionController.text,
                          imagenUrl: imagenUrlController.text,
                          artistaId: artistaController.text.toLowerCase().replaceAll(' ', '_'),
                          fechaCreacion: DateTime.now(),
                        );
                        controlador.agregarObraArte(nuevaObra);
                        tituloController.clear();
                        artistaController.clear();
                        descripcionController.clear();
                        imagenUrlController.clear();
                      }
                    },
                    child: const Text('Publicar Arte'),
                  ),
                ],
              ),
            ),
            const Divider(),
            
            // Mostrar cantidad de arte
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Arte existente (${artesDelLibro.length})',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            
            // Si no hay arte
            if (artesDelLibro.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No hay obras de arte para este libro todavía.'),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: artesDelLibro.length,
                  itemBuilder: (context, index) {
                    final arte = artesDelLibro[index];
                    return ListTile(
                      leading: Image.network(arte.imagenUrl, width: 50, fit: BoxFit.cover),
                      title: Text(arte.titulo),
                      subtitle: Text('Por ${arte.artista}'),
                    );
                  },
                ),
              ),
            
            // Botón para ver la galería completa
            if (artesDelLibro.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => GaleriaArtePage(
                      libroId: libroId,
                      tituloLibro: libro.titulo,
                      artes: artesDelLibro,
                    ));
                  },
                  child: const Text('Ver toda la galería'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
