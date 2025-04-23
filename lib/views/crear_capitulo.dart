import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';
import 'package:writerhub/widgets/controller.dart';
import 'package:writerhub/models/capitulo.dart';

class CrearCapituloPage extends StatefulWidget {
  final String libroId;
  final String tituloLibro;
  int numeroCapitulo;

  CrearCapituloPage({
    super.key,
    required this.libroId,
    required this.tituloLibro,
    required this.numeroCapitulo,
  });

  @override
  State<CrearCapituloPage> createState() => _CrearCapituloPageState();
}

class _CrearCapituloPageState extends State<CrearCapituloPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  bool _guardarComoBorrador = false;
  final Controller controller = Get.find();

  final quill.QuillController _quillController = quill.QuillController.basic();

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capítulo ${widget.numeroCapitulo} - "${widget.tituloLibro}"'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: () {
              // Navegar a otra vista si es necesario
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título del Capítulo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un título para el capítulo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              quill.QuillSimpleToolbar(controller: _quillController),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: quill.QuillEditor.basic(
                      controller: _quillController,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _guardarComoBorrador,
                    onChanged: (value) {
                      setState(() {
                        _guardarComoBorrador = value ?? false;
                      });
                    },
                  ),
                  const Text('Guardar como borrador'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _publicarCapitulo(yContinuar: false),
                      child: const Text('Publicar Capítulo'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _publicarCapitulo(yContinuar: true),
                      child: const Text('Publicar y Continuar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _publicarCapitulo({bool yContinuar = false}) async {
  if (_formKey.currentState!.validate()) {
    final contenidoJson = _quillController.document.toDelta().toJson();


    try {
      final snapshot = await FirebaseFirestore.instance
     .collection('libros')
     .doc(widget.libroId)
      .collection('capitulos')
      .get();
      final numeroCapitulo = snapshot.docs.length + 1;

      final nuevoCapitulo = {
      'titulo': _tituloController.text.trim(),
      'contenido': contenidoJson,
      'numero': numeroCapitulo,
      'fechaPublicacion': DateTime.now(),
      'borrador': _guardarComoBorrador,
      };

      final docRef = FirebaseFirestore.instance
        .collection('libros')
        .doc(widget.libroId)
        .collection('capitulos')
        .doc(); // Auto-generates a unique ID

      await docRef.set(nuevoCapitulo);

      if (yContinuar) {
        _tituloController.clear();
        _quillController.clear();
        setState(() {
          widget.numeroCapitulo++; // You might want to rethink how you track this
        });
      } else {
        Get.back();
        Get.snackbar(
          'Éxito',
          'Capítulo publicado correctamente',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo publicar el capítulo: $e');
    }
  }
}

  @override
  void dispose() {
    _tituloController.dispose();
    _quillController.dispose();
    super.dispose();
  }
}

