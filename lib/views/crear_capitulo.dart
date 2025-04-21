import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:writerhub/widgets/controller.dart';
import '../models/capitulo.dart';
import '../models/libro.dart';

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
  final TextEditingController _contenidoController = TextEditingController();
  bool _guardarComoBorrador = false;
  final Controller controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Capítulo ${widget.numeroCapitulo} - "${widget.tituloLibro}"'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: () {
              // Aquí puedes navegar a la vista de capítulos del libro
              // Ejemplo: Get.to(() => ListaCapitulosPage(libroId: widget.libroId));
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
              Expanded(
                child: TextFormField(
                  controller: _contenidoController,
                  decoration: const InputDecoration(
                    labelText: 'Contenido',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Escribe el contenido del capítulo';
                    }
                    return null;
                  },
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
      final nuevoCapitulo = Capitulo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        libroId: widget.libroId,
        titulo: _tituloController.text.trim(),
        contenido: _contenidoController.text.trim(),
        numero: widget.numeroCapitulo,
        fechaPublicacion: DateTime.now(),
      );

      await controller.agregarCapitulo(nuevoCapitulo);

      if (yContinuar) {
        _tituloController.clear();
        _contenidoController.clear();
        setState(() {
          widget.numeroCapitulo++; 
        });
      } else {
        Get.back();
        Get.snackbar(
          'Éxito',
          'Capítulo publicado correctamente',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _contenidoController.dispose();
    super.dispose();
  }
}
