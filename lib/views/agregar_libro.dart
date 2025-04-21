import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/controller.dart';
import '../models/libro.dart';

class AgregarLibro extends StatefulWidget {
  const AgregarLibro({super.key});

  @override
  State<AgregarLibro> createState() => _AgregarLibroPantallaState();
}

class _AgregarLibroPantallaState extends State<AgregarLibro> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _portadaUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Controller controlador = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Libro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _autorController,
                decoration: const InputDecoration(labelText: 'Autor'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un autor';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _portadaUrlController,
                decoration: const InputDecoration(labelText: 'URL de la portada'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final nuevoLibro = Libro(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      titulo: _tituloController.text,
                      autor: _autorController.text,
                      descripcion: _descripcionController.text,
                      portadaUrl: _portadaUrlController.text,
                      calificacion: 0,
                      lectores: 0,
                    );
                    controlador.agregarLibro(nuevoLibro);
                    Navigator.pop(context);
                  }
                },
                child: const Text('Publicar Libro'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _descripcionController.dispose();
    _portadaUrlController.dispose();
    super.dispose();
  }
}