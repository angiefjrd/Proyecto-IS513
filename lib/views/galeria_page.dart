import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:writerhub/widgets/controller.dart';
import 'package:writerhub/models/arte.dart';
import 'package:writerhub/views/subir_arte_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GaleriaArtePage extends StatelessWidget {
  final String libroId;
  final String tituloLibro;
  final List<Arte> artes;

  const GaleriaArtePage({
    super.key, 
    required this.artes,
    required this.libroId,
    required this.tituloLibro,
  });

  @override
  Widget build(BuildContext context) {
    final Controller controller = Get.find();
    controller.cargarObrasArte(libroId: libroId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Ilustraciones de $tituloLibro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.to(
              () => SubirArtePage(libroId: libroId, tituloLibro: tituloLibro),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.obrasArte.isEmpty) {
          return const Center(
            child: Text('No hay ilustraciones aún'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8,
          ),
          itemCount: controller.obrasArte.length,
          itemBuilder: (context, index) {
            final obra = controller.obrasArte[index];
            return _buildObraCard(obra, controller);
          },
        );
      }),
    );
  }

  Widget _buildObraCard(Arte obra, Controller controller) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _mostrarDetalleObra(obra),
              child: Image.network(
                obra.imagenUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  obra.titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        obra.likedBy?.contains(FirebaseAuth.instance.currentUser?.uid) ?? false
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () => controller.darLikeObra(obraId: obra.id, libroId: libroId),
                    ),
                    Text('${obra.likes ?? 0}'),
                    const Spacer(),
                    Text(
                      obra.artista,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarDetalleObra(Arte obra) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                obra.titulo,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Image.network(obra.imagenUrl),
              const SizedBox(height: 16),
              Text(obra.descripcion),
              const SizedBox(height: 16),
              Text(
                'Por ${obra.artista}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 8),
              Text(
                'Publicado el ${_formatearFecha(obra.fechaCreacion)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}