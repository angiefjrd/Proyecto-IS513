import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:writerhub/widgets/controller.dart';
import 'package:writerhub/models/arte.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:writerhub/views/subir_arte_page.dart';

class GaleriaArtePage extends StatelessWidget {
  final String libroId;
  final String tituloLibro;
  final List<Arte> artes;

  const GaleriaArtePage({
    super.key, 
    required this.libroId,
    required this.tituloLibro,
    required this.artes,
  });

  @override
  Widget build(BuildContext context) {
    final Controller controller = Get.find();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Galería de $tituloLibro'),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Get.to(
                () => SubirArtePage(
                  libroId: libroId,
                  tituloLibro: tituloLibro,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(controller),
    );
  }

  Widget _buildBody(Controller controller) {
    return Obx(() {
      final obras = controller.obrasArte.where((a) => a.libroId == libroId).toList();
      
      if (obras.isEmpty) {
        return const Center(child: Text('No hay obras de arte aún'));
      }

      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemCount: obras.length,
        itemBuilder: (context, index) {
          return _buildObraCard(obras[index], controller);
        },
      );
    });
  }

  Widget _buildObraCard(Arte obra, Controller controller) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: Image.network(
              obra.imagenUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  obra.titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  obra.artista,
                  style: const TextStyle(fontSize: 12),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        obra.likedBy.contains(FirebaseAuth.instance.currentUser?.uid) 
                            ? Icons.favorite 
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () => controller.darLikeObra(
                        obraId: obra.id, 
                        libroId: libroId,
                      ),
                    ),
                    Text('${obra.likes}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}