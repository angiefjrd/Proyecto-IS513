import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:writerhub/models/libro.dart';
import 'package:writerhub/widgets/controller.dart';
import 'package:writerhub/views/lecturacap.dart';
import 'package:writerhub/views/lecturalib.dart';
import 'package:writerhub/views/crear_capitulo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:writerhub/views/clibros.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DetalleLibroPage extends StatefulWidget {
  final String libroId;

  const DetalleLibroPage({super.key, required this.libroId});

  @override
  State<DetalleLibroPage> createState() => _DetalleLibroPageState();
}

class _DetalleLibroPageState extends State<DetalleLibroPage> {
  final Controller _controller = Get.find();
  final TextEditingController _comentarioController = TextEditingController();
  late Libro _libro;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarLibro();
  }

  Future<void> _cargarLibro() async {
    setState(() => _cargando = true);
    try {
      _libro = _controller.libros.firstWhere((l) => l.id == widget.libroId);
      if (_libro.esEnEmision) {
        await _controller.cargarCapitulos(_libro.id);
      }
      
      // Actualizar contador de vistas
      if (FirebaseAuth.instance.currentUser?.uid != _libro.autorId) {
        await FirebaseFirestore.instance
            .collection('libros')
            .doc(_libro.id)
            .update({
              'vistas': FieldValue.increment(1),
            });
        _libro = _libro.copyWith(vistas: _libro.vistas + 1);
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el libro');
    } finally {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_libro.titulo),
        actions: [
          if (_libro.esEnEmision)
            IconButton(
              icon: const Icon(Icons.auto_stories),
              onPressed: () => Get.to(
                () => LecturaCapitulosPage(libro: _libro),
              ),
            ),

        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPortada(),
            _buildInfoLibro(),
            _buildReacciones(),
            _buildSeccionCapitulos(),
            _buildComentarios(),
          ],
        ),
      ),
      floatingActionButton: _buildActionButton(),
    );
  }

  Widget _buildPortada() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey[200],
      child: _libro.portadaUrl.isNotEmpty
          ? Image.network(_libro.portadaUrl, fit: BoxFit.cover)
          : const Icon(Icons.book, size: 100),
    );
  }

  Widget _buildInfoLibro() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_libro.titulo, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('Por ${_libro.autor}', 
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber),
              Text(' ${_libro.calificacion.toStringAsFixed(1)}'),
              const SizedBox(width: 20),
              const Icon(Icons.people),
              Text(' ${_libro.lectores} lectores'),
              const SizedBox(width: 20),
              const Icon(Icons.visibility),
              Text(' ${_libro.vistas} vistas'),
            ],
          ),
          const SizedBox(height: 16),
          if (_libro.etiquetas.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              children: _libro.etiquetas.map((etiqueta) => Chip(
                label: Text(etiqueta),
                backgroundColor: Colors.deepPurple.withOpacity(0.1),
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],
          const Text('Descripción', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_libro.descripcion),
        ],
      ),
    );
  }

  Widget _buildReacciones() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Reacciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildReaccionChip('Me gusta', Icons.thumb_up),
              _buildReaccionChip('Fascinante', Icons.favorite),
              _buildReaccionChip('Increíble', Icons.star),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReaccionChip(String texto, IconData icono) {
    return ActionChip(
      avatar: Icon(icono, size: 16),
      label: Text(texto),
      onPressed: () => _controller.agregarReaccion(_libro.id, texto),
      backgroundColor: _libro.reacciones.contains(texto)
          ? Theme.of(context).primaryColor.withOpacity(0.2)
          : null,
    );
  }

  Widget _buildSeccionCapitulos() {
    if (!_libro.esEnEmision) return const SizedBox();

    return Obx(() {
      final capitulos = _controller.capitulos;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Capítulos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (capitulos.isEmpty)
              const Text('Aún no hay capítulos publicados')
            else
              Column(
                children: capitulos.take(3).map((capitulo) => ListTile(
                  title: Text('Capítulo ${capitulo.numero}: ${capitulo.titulo}'),
                  subtitle: Text(_formatearFecha(capitulo.fechaPublicacion)),
                  onTap: () => Get.to(
                    () => LecturaCapitulosPage(libro: _libro),
                    arguments: {'capituloInicial': capitulo.numero},
                  ),
                )).toList(),
              ),
            if (capitulos.length > 3)
              TextButton(
                onPressed: _mostrarListaCapitulos,
                child: const Text('Ver todos los capítulos'),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildComentarios() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Comentarios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_libro.comentarios.isEmpty)
            const Text('Sé el primero en comentar')
          else
            Column(
              children: _libro.comentarios
                  .take(3)
                  .map((c) => Comentariolib(comentario: c))
                  .toList(),
            ),
          if (_libro.comentarios.length > 3)
            TextButton(
              onPressed: () => _mostrarTodosComentarios(),
              child: const Text('Ver todos los comentarios'),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _comentarioController,
                  decoration: const InputDecoration(
                    hintText: 'Añade un comentario...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (_comentarioController.text.isNotEmpty) {
                    _controller.agregarComentario(
                      _libro.id,
                      _comentarioController.text,
                    );
                    _comentarioController.clear();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _buildActionButton() {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.uid != _libro.autorId) return null;

    return FloatingActionButton(
      onPressed: () {
        if (_libro.esEnEmision) {
          final nextChapter = _controller.capitulos.isEmpty
              ? 1
              : _controller.capitulos.last.numero + 1;
          Get.to(() => CrearCapituloPage(
                libroId: _libro.id,
                numeroCapitulo: nextChapter,
                tituloLibro: _libro.titulo,
              ))?.then((_) => _controller.cargarCapitulos(_libro.id));
        } else {
          // Opción para editar libro completo
          Get.snackbar('Editar', 'Funcionalidad de edición en desarrollo');
        }
      },
      child: Icon(_libro.esEnEmision ? Icons.add : Icons.edit),
    );
  }

  void _mostrarListaCapitulos() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Text('Capítulos de ${_libro.titulo}',
                style: Theme.of(context).textTheme.headlineSmall),
            Expanded(
              child: Obx(() {
                final capitulos = _controller.capitulos;
                return ListView.builder(
                  itemCount: capitulos.length,
                  itemBuilder: (ctx, index) {
                    final capitulo = capitulos[index];
                    return ListTile(
                      title: Text('Capítulo ${capitulo.numero}: ${capitulo.titulo}'),
                      subtitle: Text(_formatearFecha(capitulo.fechaPublicacion)),
                      onTap: () {
                        Get.back();
                        Get.to(
                          () => LecturaCapitulosPage(libro: _libro),
                          arguments: {'capituloInicial': capitulo.numero},
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarTodosComentarios() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            const Text('Todos los comentarios',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _libro.comentarios.length,
                itemBuilder: (ctx, index) {
                  return Comentariolib(
                    comentario: _libro.comentarios[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}