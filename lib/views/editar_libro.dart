import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:writerhub/widgets/controller.dart';
import '../models/libro.dart';

class EditarLibroPage extends StatefulWidget {
  final Libro libro;

  const EditarLibroPage({Key? key, required this.libro}) : super(key: key);

  @override
  _EditarLibroPageState createState() => _EditarLibroPageState();
}

class _EditarLibroPageState extends State<EditarLibroPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _autorController;
  late TextEditingController _descripcionController;
  late TextEditingController _portadaUrlController;

  late String _tipoEscrituraSeleccionado;
  bool _isSubmitting = false;
  double _uploadProgress = 0.0;
  List<String> _generosSeleccionados = [];
  PlatformFile? _nuevoArchivo;
  String? _nuevaPortadaUrl;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final List<String> _generosDisponibles = [
    'Fantasía', 'Ciencia Ficción', 'Romance', 'Terror', 
    'Misterio', 'Aventura', 'Drama', 'Comedia', 'Poesía',
  ];

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.libro.titulo);
    _autorController = TextEditingController(text: widget.libro.autor);
    _descripcionController = TextEditingController(text: widget.libro.descripcion);
    _portadaUrlController = TextEditingController(text: widget.libro.portadaUrl);
    _tipoEscrituraSeleccionado = widget.libro.esEnEmision ? 'capitulos' : 'completo';
    _generosSeleccionados = List.from(widget.libro.genres);
  }

  @override
  Widget build(BuildContext context) {
    final Controller controlador = Get.find();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Libro'),
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
              if (_tipoEscrituraSeleccionado == 'completo') _buildSeccionArchivo(),
              const SizedBox(height: 16),
              _buildBotonGuardarCambios(controlador, user),
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingrese el título';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _autorController,
          decoration: const InputDecoration(labelText: 'Autor'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingrese el autor';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descripcionController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Descripción'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingrese la descripción';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        _buildSelectorPortada(),
        _buildSelectorGeneros(),
      ],
    );
  }

  Widget _buildSelectorPortada() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _portadaUrlController,
          decoration: const InputDecoration(labelText: 'URL de portada'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _seleccionarNuevaPortada,
          child: const Text('Seleccionar nueva portada'),
        ),
        if (_nuevaPortadaUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Image.network(_nuevaPortadaUrl!, height: 100),
          ),
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

  Widget _buildSelectorMetodoEscritura() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de escritura',
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
              child: Text(value == 'completo' ? 'Libro completo' : 'Por capítulos'),
            );
          }).toList(),
          decoration: const InputDecoration(labelText: 'Tipo de escritura'),
        ),
      ],
    );
  }

  Widget _buildSeccionArchivo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Archivo del libro',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (widget.libro.archivoUrl != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Archivo actual: ${widget.libro.nombreArchivo ?? 'Sin nombre'}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ElevatedButton(
          onPressed: _seleccionarNuevoArchivo,
          child: const Text('Seleccionar nuevo archivo'),
        ),
        if (_nuevoArchivo != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Nuevo archivo: ${_nuevoArchivo!.name}',
              style: const TextStyle(fontSize: 14),
            ),
          ),
      ],
    );
  }

  Future<void> _seleccionarNuevoArchivo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['docx', 'txt', 'pdf', 'epub'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _nuevoArchivo = result.files.first;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo seleccionar el archivo: ${e.toString()}');
    }
  }

  Future<void> _seleccionarNuevaPortada() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _isSubmitting = true;
        });

        final file = result.files.first;
        final extension = path.extension(file.name).replaceFirst('.', '');
        final ref = _storage.ref().child(
            'portadas/${DateTime.now().millisecondsSinceEpoch}.$extension');

        final uploadTask = ref.putData(file.bytes!);
        
        uploadTask.snapshotEvents.listen((taskSnapshot) {
          setState(() {
            _uploadProgress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
          });
        });

        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          _nuevaPortadaUrl = downloadUrl;
          _portadaUrlController.text = downloadUrl;
          _isSubmitting = false;
          _uploadProgress = 0.0;
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo subir la portada: ${e.toString()}');
      setState(() {
        _isSubmitting = false;
        _uploadProgress = 0.0;
      });
    }
  }

  Future<String?> _subirNuevoArchivo() async {
    if (_nuevoArchivo == null) return null;

    try {
      final extension = path.extension(_nuevoArchivo!.name).replaceFirst('.', '');
      final ref = _storage.ref().child(
          'libros/${DateTime.now().millisecondsSinceEpoch}.$extension');

      final metadata = SettableMetadata(
        contentType: _getMimeType(extension),
        customMetadata: {
          'uploadedBy': FirebaseAuth.instance.currentUser?.uid ?? 'anon',
          'originalName': _nuevoArchivo!.name,
        },
      );

      final uploadTask = ref.putData(_nuevoArchivo!.bytes!, metadata);
      
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

  Future<void> _guardarCambios(Controller controlador, User? user) async {
  if (!_formKey.currentState!.validate()) return;
  if (user == null) {
    Get.snackbar('Error', 'Debes iniciar sesión para editar');
    return;
  }

  if (_generosSeleccionados.isEmpty) {
    Get.snackbar('Error', 'Debes seleccionar al menos un género');
    return;
  }

  setState(() {
    _isSubmitting = true;
    _uploadProgress = 0.0;
  });

  try {
    // Variables para el archivo y su nombre
    String? nuevoArchivoUrl;
    String? nuevoNombreArchivo;

    // Subir nuevo archivo si se seleccionó
    if (_nuevoArchivo != null) {
      nuevoArchivoUrl = await _subirNuevoArchivo();
      nuevoNombreArchivo = _nuevoArchivo!.name;
    }

    // Crear libro actualizado con los datos del formulario
    final libroActualizado = widget.libro.copyWith(
      titulo: _tituloController.text.trim(),
      autor: _autorController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      portadaUrl: _portadaUrlController.text.trim().isEmpty 
          ? widget.libro.portadaUrl 
          : _portadaUrlController.text.trim(),
      archivoUrl: nuevoArchivoUrl ?? widget.libro.archivoUrl,
      nombreArchivo: nuevoNombreArchivo ?? widget.libro.nombreArchivo, 
      esEnEmision: _tipoEscrituraSeleccionado == 'capitulos',
      ultimaActualizacion: DateTime.now(),
      genres: _generosSeleccionados,
    );

    // Actualizar libro en Firestore
    await _firestore.collection('libros').doc(widget.libro.id).update(libroActualizado.toJson());
    
    // Actualizar el libro en la lista del controlador
    final index = controlador.libros.indexWhere((l) => l.id == widget.libro.id);
    if (index != -1) {
      controlador.libros[index] = libroActualizado;
    }

    // Cerrar pantalla de edición y mostrar mensaje de éxito
    Get.back();
    Get.snackbar('Éxito', 'Libro actualizado correctamente');
  } catch (e) {
    Get.snackbar('Error', 'Actualización fallida: ${e.toString()}');
  } finally {
    setState(() {
      _isSubmitting = false;
      _uploadProgress = 0.0;
    });
  }
}

  Widget _buildBotonGuardarCambios(Controller controlador, User? user) {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : () => _guardarCambios(controlador, user),
      child: _isSubmitting
          ? const CircularProgressIndicator()
          : const Text('Guardar Cambios'),
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