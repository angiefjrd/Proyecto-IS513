import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:writerhub/models/libro.dart';
import 'package:writerhub/widgets/controller.dart';
import 'package:writerhub/views/lecturacap.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:writerhub/models/capitulo.dart';
import '../views/crear_capitulo.dart';

class LecturaLibroPage extends StatelessWidget {
  final Libro libro;

  const LecturaLibroPage({super.key, required this.libro});

  @override
  Widget build(BuildContext context) {
    final Controller controller = Get.find();
    controller.cargarCapitulos(libro.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(libro.titulo),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _compartirLibro(context),
          ),
          if (libro.esEnEmision)
            IconButton(
              icon: const Icon(Icons.menu_book),
              onPressed: () => Get.to(() => LecturaCapitulosPage(
                libro: libro,
                capituloInicial: controller.ultimoCapituloLeido[libro.id] ?? 1,
              )),
              tooltip: 'Ver capítulos',
            ),
        ],
      ),
      body: _buildContent(controller),
      floatingActionButton: _buildFab(controller),
    );
  }

  Widget _buildContent(Controller controller) {
    if (libro.esEnEmision) {
      return Obx(() {
        if (controller.capitulos.isEmpty) {
          return _buildEmptyChapters();
        }
        
        final ultimoLeido = controller.ultimoCapituloLeido[libro.id] ?? 1;
        final capituloAMostrar = controller.capitulos.firstWhere(
          (c) => c.numero == ultimoLeido,
          orElse: () => controller.capitulos.first,
        );
        
        return _buildChapterContent(capituloAMostrar);
      });
    }
    return _buildFullBookContent();
  }

  Widget _buildEmptyChapters() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.book, size: 50, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'Aún no hay capítulos publicados',
            style: Get.textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 10),
          if (libro.autorId == FirebaseAuth.instance.currentUser?.uid)
            ElevatedButton(
              onPressed: _crearPrimerCapitulo,
              child: const Text('Crear primer capítulo'),
            ),
        ],
      ),
    );
  }

  Widget _buildChapterContent(Capitulo capitulo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Capítulo ${capitulo.numero}: ${capitulo.titulo}',
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Publicado el ${_formatearFecha(capitulo.fechaPublicacion)}',
            style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Text(
            capitulo.contenido,
            style: Get.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              fontSize: 16,
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 40),
          if (libro.esEnEmision)
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => Get.to(() => LecturaCapitulosPage(
                  libro: libro,
                  capituloInicial: capitulo.numero,
                )),
                child: const Text('Ver todos los capítulos'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFullBookContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (libro.portadaUrl.isNotEmpty)
            Center(
              child: Image.network(
                libro.portadaUrl,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.book, size: 100),
              ),
            ),
          const SizedBox(height: 20),
          Text(
            libro.titulo,
            style: Get.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Por ${libro.autor}',
            style: Get.textTheme.titleMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Descripción',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            libro.descripcion,
            style: Get.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Contenido',
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            libro.contenidoCompleto ?? '[Contenido no disponible]',
            style: Get.textTheme.bodyLarge?.copyWith(
              height: 1.6,
              fontSize: 16,
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget? _buildFab(Controller controller) {
    if (libro.esEnEmision) {
      if (controller.capitulos.isEmpty) return null;
      
      return FloatingActionButton(
        onPressed: () {
          final ultimoLeido = controller.ultimoCapituloLeido[libro.id] ?? 1;
          Get.to(() => LecturaCapitulosPage(
            libro: libro,
            capituloInicial: ultimoLeido,
          ));
        },
        tooltip: 'Continuar leyendo',
        child: const Icon(Icons.auto_stories),
      );
    }
    
    return FloatingActionButton(
      onPressed: () => _guardarMarcador(controller),
      tooltip: 'Guardar marcador',
      child: const Icon(Icons.bookmark),
    );
  }

  void _crearPrimerCapitulo() {
    Get.to(() => CrearCapituloPage(
      libroId: libro.id,
      numeroCapitulo: 1,
    ));
  }

  void _guardarMarcador(Controller controller) {
    if (libro.esEnEmision && controller.capitulos.isNotEmpty) {
      final currentChapter = controller.capitulos
          .firstWhereOrNull((c) => c.numero == (controller.ultimoCapituloLeido[libro.id] ?? 1));
      
      if (currentChapter != null) {
        controller.ultimoCapituloLeido[libro.id] = currentChapter.numero;
      }
    }
    
    Get.snackbar(
      'Marcador guardado',
      'Tu progreso de lectura ha sido guardado',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _compartirLibro(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compartir libro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Copiar enlace'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar(
                  'Enlace copiado',
                  'El enlace ha sido copiado al portapapeles',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartir en redes'),
              onTap: () {
                Navigator.pop(context);
                // Implementar lógica para compartir en redes
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
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