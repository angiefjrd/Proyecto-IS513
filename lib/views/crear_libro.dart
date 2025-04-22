import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
  final _portadaUrlController = TextEditingController();

  String _tipoEscrituraSeleccionado = 'completo';
  bool _isSubmitting = false;
  PlatformFile? _archivoSeleccionado;
  double _uploadProgress = 0.0;

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
        actions: [
          if (_isSubmitting && _uploadProgress > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSeccionBasica(),
              _buildSelectorMetodoEscritura(),
              if (_tipoEscrituraSeleccionado == 'completo') _buildImportarArchivo(),
              const SizedBox(height: 16),
              _buildBotonPublicacion(controlador, user),
              if (_isSubmitting && _uploadProgress > 0) _buildProgressIndicator(),
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
        TextFormField(
          controller: _portadaUrlController,
          decoration: const InputDecoration(labelText: 'URL de portada (opcional)'),
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

  // Método para seleccionar el tipo de escritura
  Widget _buildSelectorMetodoEscritura() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona el tipo de escritura',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _tipoEscrituraSeleccionado,
          onChanged: (value) {
            setState(() {
              _tipoEscrituraSeleccionado = value ?? 'completo';
            });
          },
          items: <String>['completo', 'capitulos']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          decoration: const InputDecoration(labelText: 'Tipo de escritura'),
        ),
      ],
    );
  }

  // Método para importar archivo
  Widget _buildImportarArchivo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Importar archivo',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _seleccionarArchivo,
          child: const Text('Seleccionar archivo'),
        ),
        if (_archivoSeleccionado != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Archivo seleccionado: ${_archivoSeleccionado!.name}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }

  Future<void> _seleccionarArchivo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['docx', 'txt', 'pdf', 'epub'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _archivoSeleccionado = result.files.first;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo seleccionar el archivo: ${e.toString()}');
    }
  }

  Future<String> _subirArchivo(PlatformFile archivo) async {
    try {
      if (archivo.bytes == null) {
        throw Exception('El archivo no contiene datos');
      }

      final extension = path.extension(archivo.name).replaceFirst('.', '');
      final ref = _storage.ref().child(
          'libros/${DateTime.now().millisecondsSinceEpoch}.$extension');

      final metadata = SettableMetadata(
        contentType: _getMimeType(extension),
        customMetadata: {
          'uploadedBy': FirebaseAuth.instance.currentUser?.uid ?? 'anon',
          'originalName': archivo.name,
        },
      );

      final uploadTask = ref.putData(archivo.bytes!, metadata);
      
      uploadTask.snapshotEvents.listen((taskSnapshot) {
        setState(() {
          _uploadProgress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
        });
      });

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error al subir archivo: $e');
    }
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'epub':
        return 'application/epub+zip';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

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

    if (_tipoEscrituraSeleccionado == 'completo' && _archivoSeleccionado == null) {
      Get.snackbar('Error', 'Debes seleccionar un archivo para el libro completo');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _uploadProgress = 0.0;
    });

    try {
      String? archivoUrl;
      String? nombreArchivo;

      if (_tipoEscrituraSeleccionado == 'completo' && _archivoSeleccionado != null) {
        archivoUrl = await _subirArchivo(_archivoSeleccionado!);
        nombreArchivo = _archivoSeleccionado!.name;
      }

      final libro = Libro(
        id: _firestore.collection('libros').doc().id,
        titulo: _tituloController.text.trim(),
        autor: _autorController.text.trim(),
        autorId: user.uid,
        portadaUrl: _portadaUrlController.text.trim().isEmpty? '' 
        : _portadaUrlController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        archivoUrl: archivoUrl,
        nombreArchivo: nombreArchivo,
        esEnEmision: _tipoEscrituraSeleccionado == 'capitulos',
        fechaCreacion: DateTime.now(),
        ultimaActualizacion: DateTime.now(),
        calificacion: 0,
        lectores: 0,
        reacciones: [],
        comentarios: [],
        capitulos: _tipoEscrituraSeleccionado == 'capitulos' ? [] : null,
        genres: _generosSeleccionados,
      );

      await _firestore.collection('libros').doc(libro.id).set(libro.toJson());
      controlador.agregarLibro(libro);

      if (_tipoEscrituraSeleccionado == 'capitulos') {
        Get.off(() => CrearCapituloPage(
              libroId: libro.id,
              tituloLibro: libro.titulo,
              numeroCapitulo: 1,
            ));
      } else {
        Get.back();
        Get.snackbar('Éxito', 'Libro publicado correctamente');
      }
    } catch (e) {
      Get.snackbar('Error', 'Publicación fallida: ${e.toString()}');
    } finally {
      setState(() {
        _isSubmitting = false;
        _uploadProgress = 0.0;
      });
    }
  }

  Widget _buildBotonPublicacion(Controller controlador, User? user) {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : () => _publicarLibro(controlador, user),
      child: _isSubmitting
          ? const CircularProgressIndicator()
          : const Text('Publicar Libro'),
    );
  }

  Widget _buildProgressIndicator() {
    return LinearProgressIndicator(
      value: _uploadProgress,
      backgroundColor: Colors.grey[200],
      color: Colors.blue,
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
