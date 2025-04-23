import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:writerhub/widgets/controller.dart';
import 'package:writerhub/models/arte.dart';
import 'dart:io';

class SubirArtePage extends StatefulWidget {
  final String libroId;
  final String tituloLibro;

  const SubirArtePage({
    super.key,
    required this.libroId,
    required this.tituloLibro,
  });

  @override
  State<SubirArtePage> createState() => _SubirArtePageState();
}

class _SubirArtePageState extends State<SubirArtePage> {
  final Controller _controller = Get.find();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _etiquetasController = TextEditingController();
  File? _imagenSeleccionada;
  double _uploadProgress = 0;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subir Ilustración'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _seleccionarImagen,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _imagenSeleccionada != null
                      ? Image.file(_imagenSeleccionada!, fit: BoxFit.cover)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 50),
                            Text('Seleccionar imagen'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _etiquetasController,
                decoration: const InputDecoration(
                  labelText: 'Etiquetas (separadas por comas)',
                  hintText: 'ej. digital, acuarela, fanart',
                ),
              ),
              const SizedBox(height: 16),
              if (_isUploading)
                LinearProgressIndicator(
                  value: _uploadProgress,
                  minHeight: 8,
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isUploading ? null : _subirObra,
                child: const Text('Publicar Ilustración'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  Future<void> _subirObra() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imagenSeleccionada == null) {
      Get.snackbar('Error', 'Selecciona una imagen');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'Debes iniciar sesión');
        return;
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('arte/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = storageRef.putFile(_imagenSeleccionada!);
      uploadTask.snapshotEvents.listen((taskSnapshot) {
        setState(() {
          _uploadProgress =
              taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
        });
      });

      final snapshot = await uploadTask.whenComplete(() {});
      final imageUrl = await snapshot.ref.getDownloadURL();

      final nuevaObra = Arte(
        id: '', // ID será asignado por Firestore
        libroId: widget.libroId,
        titulo: _tituloController.text.trim(),
        artista: user.displayName ?? 'Anónimo',
        artistaId: user.uid,
        imagenUrl: imageUrl,
        descripcion: _descripcionController.text.trim(),
        fechaCreacion: DateTime.now(),
        etiquetas: _etiquetasController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
      );

      await _controller.agregarObraArte(nuevaObra);
      Get.back();
      Get.snackbar('Éxito', 'Ilustración publicada');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo subir la ilustración: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _etiquetasController.dispose();
    super.dispose();
  }
}
