import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String? _selectedReaction;

  @override
  Widget build(BuildContext context) {
    final Controller controlador = Get.find();
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Añadir Libro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
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
                    if (!Uri.tryParse(value)!.hasAbsolutePath) {
                      return 'Ingresa una URL válida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButton<String>(
                  value: _selectedReaction,
                  hint: const Text('Selecciona una reacción'),
                  items: <String>['me gusta', 'increíble', 'fascinante']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedReaction = newValue;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && user != null) {
                      try {
                        final nuevoLibro = Libro(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          titulo: _tituloController.text.trim(),
                          autor: _autorController.text.trim(),
                          autorId: user.uid,
                          descripcion: _descripcionController.text.trim(),
                          portadaUrl: _portadaUrlController.text.trim(),
                          calificacion: 0,
                          lectores: 0,
                          reacciones: _selectedReaction != null 
                              ? [_selectedReaction!] 
                              : [],
                          fechaCreacion: DateTime.now(),
                          genres: [],
                          ultimaActualizacion: DateTime.now(),
                          vistas: 0,
                        );

                        await controlador.agregarLibro(nuevoLibro);
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    }
                  },
                  child: const Text('Publicar Libro'),
                ),
              ],
            ),
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