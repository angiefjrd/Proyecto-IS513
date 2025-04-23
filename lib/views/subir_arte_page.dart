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
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  double _uploadProgress = 0;

  Future<void> _seleccionarImagen() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  Future<void> _subirObra() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imagenSeleccionada == null) {
      Get.snackbar('Error', 'Por favor selecciona una imagen');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuario no autenticado');

      // 1. Subir imagen a Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('obras_arte/${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      final uploadTask = storageRef.putFile(_imagenSeleccionada!);
      
      // Mostrar progreso
      uploadTask.snapshotEvents.listen((taskSnapshot) {
        setState(() {
          _uploadProgress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
        });
      });

      // Esperar a que termine la subida
      final taskSnapshot = await uploadTask.whenComplete(() {});
      
      // Obtener URL de descarga
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // 2. Crear el objeto Arte con la URL
      final nuevaObra = Arte(
        id: '', // Se asignará al crear el documento
        libroId: widget.libroId,
        titulo: _tituloController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        imagenUrl: downloadUrl,
        artista: user.displayName ?? 'Anónimo',
        artistaId: user.uid,
        likes: 0,
        likedBy: [],
        fechaCreacion: DateTime.now(),
      );

      // 3. Guardar en Firestore
      final controller = Get.find<Controller>();
      await controller.agregarObraArte(nuevaObra);
      
      Get.back();
      Get.snackbar('Éxito', 'Obra de arte publicada correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo subir la obra: ${e.toString()}');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subir arte para ${widget.tituloLibro}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Selector de imagen
                GestureDetector(
                  onTap: _seleccionarImagen,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _imagenSeleccionada != null
                        ? Image.file(_imagenSeleccionada!, fit: BoxFit.cover)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_photo_alternate, size: 50),
                              Text('Seleccionar imagen'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Campos del formulario
                TextFormField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
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
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                
                // Barra de progreso
                if (_isUploading)
                  Column(
                    children: [
                      LinearProgressIndicator(value: _uploadProgress),
                      Text('Subiendo: ${(_uploadProgress * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                
                // Botón de subir
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _subirObra,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _isUploading ? 'Subiendo...' : 'Publicar Obra',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}