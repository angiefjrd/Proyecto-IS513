import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:writerhub/widgets/controller.dart';
import '../models/libro.dart';
import 'crear_capitulo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CrearLibroPage extends StatefulWidget {
  const CrearLibroPage({super.key});

  @override
  State<CrearLibroPage> createState() => _CrearLibroPageState();
}

class _CrearLibroPageState extends State<CrearLibroPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _portadaUrlController = TextEditingController();
  final TextEditingController _contenidoController = TextEditingController();
  bool _esEnEmision = false;

  @override
  Widget build(BuildContext context) {
    final Controller controlador = Get.find();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Libro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título del Libro',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _autorController,
                decoration: const InputDecoration(
                  labelText: 'Autor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el autor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción breve',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _portadaUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de la portada (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Libro en emisión (publicar por capítulos)'),
                value: _esEnEmision,
                onChanged: (value) {
                  setState(() {
                    _esEnEmision = value ?? false;
                  });
                },
              ),
              if (!_esEnEmision) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contenidoController,
                  decoration: const InputDecoration(
                    labelText: 'Contenido completo del libro',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 10,
                  validator: (value) {
                    if (!_esEnEmision && (value == null || value.isEmpty)) {
                      return 'Por favor escribe el contenido del libro';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _publicarLibro(controlador, user),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Publicar Libro'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _publicarLibro(Controller controlador, User? user) async {
    if (_formKey.currentState!.validate()) {
      final nuevoLibro = Libro(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: _tituloController.text,
        autor: _autorController.text,
        autorId: user?.uid ?? '',
        portadaUrl: _portadaUrlController.text,
        descripcion: _descripcionController.text,
        contenidoCompleto: _esEnEmision ? null : _contenidoController.text,
        esEnEmision: _esEnEmision,
        fechaCreacion: DateTime.now(),
        calificacion: 0,
        lectores: 0,
        reacciones: [],
      );

      await controlador.agregarLibro(nuevoLibro);

      if (_esEnEmision) {
        Get.to(() => CrearCapituloPage(
          libroId: nuevoLibro.id,
          numeroCapitulo: 1,
        ));
      } else {
        Get.back();
        Get.snackbar(
          'Éxito',
          'Libro publicado correctamente',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _descripcionController.dispose();
    _portadaUrlController.dispose();
    _contenidoController.dispose();
    super.dispose();
  }
}