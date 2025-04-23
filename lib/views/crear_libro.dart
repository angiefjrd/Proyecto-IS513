import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:writerhub/widgets/controller.dart';
import '../models/libro.dart';
import 'crear_capitulo.dart';
import 'package:file_picker/file_picker.dart';

class CrearLibroPage extends StatefulWidget {
  const CrearLibroPage({Key? key}) : super(key: key);

  @override
  _CrearLibroPageState createState() => _CrearLibroPageState();
}

class _CrearLibroPageState extends State<CrearLibroPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  final _descripcionController = TextEditingController();

  File? _imagenPortada;
  final ImagePicker _picker = ImagePicker();

  bool _isSubmitting = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final List<String> _generosDisponibles = [
    'Fantasía', 'Ciencia Ficción', 'Romance', 'Terror', 'Misterio', 'Aventura', 'Drama', 'Comedia', 'Poesía',
  ];

  final List<String> _generosSeleccionados = [];

  @override
  Widget build(BuildContext context) {
    final controlador = Get.find<Controller>();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Libro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSeccionBasica(),
              const SizedBox(height: 16),
              _buildBotonPublicacion(controlador, user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeccionBasica() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Información Básica',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _tituloController,
          decoration: const InputDecoration(labelText: 'Título'),
          validator: (value) => value == null || value.isEmpty ? 'Ingrese el título' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _autorController,
          decoration: const InputDecoration(labelText: 'Autor'),
          validator: (value) => value == null || value.isEmpty ? 'Ingrese el autor' : null,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descripcionController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Descripción'),
          validator: (value) => value == null || value.isEmpty ? 'Ingrese la descripción' : null,
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _seleccionarImagen,
          child: const Text('Seleccionar portada'),
        ),
        if (_imagenPortada != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Image.file(
              _imagenPortada!,
              height: 150,
            ),
          ),
        _buildSelectorGeneros(),
      ],
    );
  }

  Widget _buildSelectorGeneros() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Selecciona los géneros',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _generosDisponibles.map((genero) {
            return FilterChip(
              label: Text(genero),
              selected: _generosSeleccionados.contains(genero),
              onSelected: (bool seleccionado) {
                setState(() {
                  if (seleccionado) {
                    _generosSeleccionados.add(genero);
                  } else {
                    _generosSeleccionados.remove(genero);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _seleccionarImagen() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagenPortada = File(pickedFile.path);
      });
    }
  }

  Future<String?> _subirPortada() async {
    if (_imagenPortada == null) return null;
    final ref = _storage.ref().child('portadas/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = ref.putFile(_imagenPortada!);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Método para publicar el libro
  
  // Future<void> _publicarLibro(Controller controlador, User? user) async {
  //   if (!_formKey.currentState!.validate()) return;
  //   if (user == null) {
  //     Get.snackbar('Error', 'Debes iniciar sesión para publicar');
  //     return;
  //   }

  //   if (_generosSeleccionados.isEmpty) {
  //     Get.snackbar('Error', 'Debes seleccionar al menos un género');
  //     return;
  //   }

  //   setState(() {
  //     _isSubmitting = true;
  //   });

  //   try {
  //     final portadaUrl = await _subirPortada();

  //     final libro = Libro(
  //       id: _firestore.collection('libros').doc().id,
  //       titulo: _tituloController.text.trim(),
  //       autor: _autorController.text.trim(),
  //       autorId: user.uid,
  //       vistas: 0,
  //       portadaUrl: portadaUrl ?? '',
  //       descripcion: _descripcionController.text.trim(),
  //       archivoUrl: null,
  //       nombreArchivo: null,
  //       esEnEmision: true,
  //       fechaCreacion: DateTime.now(),
  //       ultimaActualizacion: DateTime.now(),
  //       calificacion: 0,
  //       lectores: 0,
  //       reacciones: [],
  //       comentarios: [],
  //       capitulos: [],
  //       genres: _generosSeleccionados,
  //     );

  //     await _firestore.collection('libros').doc(libro.id).set(libro.toJson());
  //     controlador.agregarLibro(libro);

  //     // Mostrar diálogo de éxito con opción de crear capítulos
  //     await Get.dialog(
  //       AlertDialog(
  //         title: const Text('¡Libro publicado!'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Icon(Icons.check_circle, color: Colors.green, size: 50),
  //             const SizedBox(height: 16),
  //             Text(
  //               'Tu libro "${libro.titulo}" ha sido publicado exitosamente',
  //               textAlign: TextAlign.center,
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Get.off(() => CrearCapituloPage(
  //                     libroId: libro.id,
  //                     tituloLibro: libro.titulo,
  //                     numeroCapitulo: 1,
  //                   ));
  //             },
  //             child: const Text('Crear Capítulo'),
  //           ),
  //         ],
  //       ),
  //     );
  //   } catch (e) {
  //     Get.snackbar('Error', 'Publicación fallida: ${e.toString()}');
  //   } finally {
  //     setState(() {
  //       _isSubmitting = false;
  //     });
  //   }
  // }

  Future<void> _publicarLibro(Controller controlador, User? user) async {
  if (!_formKey.currentState!.validate()) return;
  if (user == null) {
    Get.snackbar('Error', 'Debes iniciar sesión para publicar');
    return;
  }

  if (_generosSeleccionados.isEmpty) {
    Get.snackbar('Error', 'Debes seleccionar al menos un género');
    return;
  }

  setState(() {
    _isSubmitting = true;
  });

  try {
    showLoadingDialog(context);

    String imageUrl = '';
    if (_imagenPortada != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('portadas/${DateTime.now().toIso8601String()}.jpg');
      final uploadTask = await storageRef.putFile(_imagenPortada!);
      imageUrl = await uploadTask.ref.getDownloadURL();
    }

    // Generar keywords a partir de título y descripción
    String combinedText =
        '${_tituloController.text} ${_descripcionController.text}';
    List<String> keywords = combinedText
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 3)
        .map((word) => word.toLowerCase())
        .toSet()
        .toList();

    final libroRef = _firestore.collection('libros').doc();
    final libro = Libro(
      id: libroRef.id,
      titulo: _tituloController.text.trim(),
      autor: _autorController.text.trim(),
      autorId: user.uid,
      vistas: 0,
      portadaUrl: imageUrl,
      descripcion: _descripcionController.text.trim(),
      archivoUrl: null,
      nombreArchivo: null,
      esEnEmision: true,
      fechaCreacion: DateTime.now(),
      ultimaActualizacion: DateTime.now(),
      calificacion: 0,
      lectores: 0,
      reacciones: [],
      comentarios: [],
      capitulos: [],
      genres: _generosSeleccionados,
    );

    await libroRef.set(libro.toJson());
    controlador.agregarLibro(libro);

    Navigator.of(context).pop(); // Cierra el loading

    await Get.dialog(
      AlertDialog(
        title: const Text('¡Libro publicado!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 50),
            const SizedBox(height: 16),
            Text(
              'Tu libro "${libro.titulo}" ha sido publicado exitosamente',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.off(() => CrearCapituloPage(
                    libroId: libro.id,
                    tituloLibro: libro.titulo,
                    numeroCapitulo: 1,
                  ));
            },
            child: const Text('Crear Capítulo'),
          ),
        ],
      ),
    );
  } catch (e) {
    Navigator.of(context).pop(); // Cierra el loading
    Get.snackbar('Error', 'Error al publicar el libro',
        backgroundColor: Colors.red, colorText: Colors.white);
  } finally {
    setState(() {
      _isSubmitting = false;
    });
  }
}


  // Método para crear el botón de publicación
  Widget _buildBotonPublicacion(Controller controlador, User? user) {
    return ElevatedButton(
      onPressed: () async {
        await _publicarLibro(controlador, user);
      },
      child: const Text('Publicar Libro'),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true, 
    builder: (BuildContext context) {
      return const AlertDialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        content: Center(
          child: CircularProgressIndicator(),
        ),
      );
    },
  );
}
