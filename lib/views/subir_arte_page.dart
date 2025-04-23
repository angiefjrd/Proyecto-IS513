import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:writerhub/widgets/controller.dart';
import 'package:writerhub/models/arte.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart'; 

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
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // Corregido
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
      if (user == null) throw Exception('Usuario no autenticado');

      // Subir imagen a Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('arte/${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      final uploadTask = ref.putFile(_imagenSeleccionada!);
      uploadTask.snapshotEvents.listen((taskSnapshot) {
        setState(() {
          _uploadProgress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
        });
      });

      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();

      // Crear objeto Arte
      final nuevaObra = Arte(
        id: '', // Firestore asignará ID
        libroId: widget.libroId,
        titulo: _tituloController.text.trim(),
        artista: user.displayName ?? 'Anónimo',
        artistaId: user.uid,
        imagenUrl: imageUrl,
        descripcion: _descripcionController.text.trim(),
        fechaCreacion: DateTime.now(),
      );

      // Guardar en Firestore
      final docRef = await FirebaseFirestore.instance.collection('arte').add(nuevaObra.toMap());
      
      Get.back();
      Get.snackbar('Éxito', 'Obra de arte publicada');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo subir: ${e.toString()}');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subir arte para ${widget.tituloLibro}')),
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
                            children: [
                              Icon(Icons.add_photo_alternate, size: 50),
                              Text('Seleccionar imagen'),
                            ],
                          ),
                  ),
                ),
                
                // Formulario
                TextFormField(
                  controller: _tituloController,
                  decoration: InputDecoration(labelText: 'Título'),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: _descripcionController,
                  decoration: InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
                
                // Progress bar
                if (_isUploading) LinearProgressIndicator(value: _uploadProgress),
                
                // Botón de subir
                ElevatedButton(
                  onPressed: _isUploading ? null : _subirObra,
                  child: Text(_isUploading ? 'Subiendo...' : 'Publicar Arte'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
