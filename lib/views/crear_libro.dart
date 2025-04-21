import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:writerhub/widgets/controller.dart';
import '../models/libro.dart';
import 'crear_capitulo.dart';

class CrearLibroPage extends StatefulWidget {
  const CrearLibroPage({super.key});

  @override
  State<CrearLibroPage> createState() => _CrearLibroPageState();
}

class _CrearLibroPageState extends State<CrearLibroPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _portadaUrlController = TextEditingController();
  final _contenidoController = TextEditingController();

  String _tipoEscrituraSeleccionado = 'directa';
  bool _esEnEmision = false;

  @override
  Widget build(BuildContext context) {
    final controlador = Get.find<Controller>();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nuevo Libro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _mostrarAyuda,
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
              if (_tipoEscrituraSeleccionado == 'directa') _buildEscrituraDirecta(),
              if (_tipoEscrituraSeleccionado == 'capitulos') _buildPublicacionPorCapitulos(),
              if (_tipoEscrituraSeleccionado == 'importar') _buildImportarArchivo(),
              _buildBotonPublicacion(controlador, user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeccionBasica() {
    return Column(
      children: [
        TextFormField(
          controller: _tituloController,
          decoration: const InputDecoration(
            labelText: 'Título del Libro',
            border: OutlineInputBorder(),
            hintText: 'Ej: El secreto de las estrellas',
          ),
          validator: (value) =>
              (value == null || value.isEmpty) ? 'Por favor ingresa un título' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _autorController,
          decoration: const InputDecoration(
            labelText: 'Autor',
            border: OutlineInputBorder(),
            hintText: 'Tu nombre o seudónimo',
          ),
          validator: (value) =>
              (value == null || value.isEmpty) ? 'Por favor ingresa el autor' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descripcionController,
          decoration: const InputDecoration(
            labelText: 'Descripción breve',
            border: OutlineInputBorder(),
            hintText: 'Resumen atractivo de tu obra (máx. 200 caracteres)',
          ),
          maxLines: 3,
          maxLength: 200,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa una descripción';
            } else if (value.length > 200) {
              return 'La descripción es demasiado larga';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _portadaUrlController,
          decoration: const InputDecoration(
            labelText: 'URL de la portada (opcional)',
            border: OutlineInputBorder(),
            hintText: 'https://ejemplo.com/portada.jpg',
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSelectorMetodoEscritura() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Método de escritura', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile<String>(
              title: const Text('Escribir directamente'),
              subtitle: const Text('Escribe tu historia completa aquí mismo'),
              value: 'directa',
              groupValue: _tipoEscrituraSeleccionado,
              onChanged: (value) {
                setState(() {
                  _tipoEscrituraSeleccionado = value!;
                  _esEnEmision = false;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Publicar por capítulos'),
              subtitle: const Text('Irás añadiendo capítulos progresivamente'),
              value: 'capitulos',
              groupValue: _tipoEscrituraSeleccionado,
              onChanged: (value) {
                setState(() {
                  _tipoEscrituraSeleccionado = value!;
                  _esEnEmision = true;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Importar archivo'),
              subtitle: const Text('Sube un documento con tu historia'),
              value: 'importar',
              groupValue: _tipoEscrituraSeleccionado,
              onChanged: (value) {
                setState(() {
                  _tipoEscrituraSeleccionado = value!;
                  _esEnEmision = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEscrituraDirecta() {
    return Column(
      children: [
        const SizedBox(height: 16),
        TextFormField(
          controller: _contenidoController,
          decoration: const InputDecoration(
            labelText: 'Contenido completo del libro',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 15,
          validator: (value) {
            if (_tipoEscrituraSeleccionado == 'directa' &&
                (value == null || value.isEmpty)) {
              return 'Por favor escribe el contenido del libro';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Puedes escribir tu historia directamente aquí. Recuerda guardar con frecuencia.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildPublicacionPorCapitulos() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Card(
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: const [
                Icon(Icons.timelapse, size: 40, color: Colors.blue),
                SizedBox(height: 8),
                Text('Publicación por capítulos', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  'Después de crear el libro, podrás añadir capítulos uno por uno.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImportarArchivo() {
    return Column(
      children: [
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: const Text('Seleccionar archivo'),
          onPressed: _seleccionarArchivo,
        ),
        const SizedBox(height: 8),
        Text(
          'Formatos soportados: .docx, .txt, .pdf',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildBotonPublicacion(Controller controlador, User? user) {
    return Column(
      children: [
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => _publicarLibro(controlador, user),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
          child: const Text('Publicar libro'),
        ),
      ],
    );
  }

  void _mostrarAyuda() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ayuda'),
        content: const Text(
          'Selecciona el método de escritura que prefieras. Puedes escribir directamente, importar un archivo o comenzar por capítulos.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Entendido')),
        ],
      ),
    );
  }

  void _seleccionarArchivo() {
    // Implementación futura: selector de archivos
    Get.snackbar('Función no disponible', 'Pronto podrás importar archivos desde tu dispositivo.');
  }

  void _publicarLibro(Controller controlador, User? user) {
    if (_formKey.currentState!.validate()) {
      final libro = Libro(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titulo: _tituloController.text.trim(),
        autor: _autorController.text.trim(),
        autorId: user?.uid ?? 'desconocido',
        portadaUrl: _portadaUrlController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        contenidoCompleto: _tipoEscrituraSeleccionado == 'directa'
            ? _contenidoController.text.trim()
            : null,
        esEnEmision: _esEnEmision,
        fechaCreacion: DateTime.now(),
        calificacion: 0,
        lectores: 0,
        reacciones: [],
        comentarios: [],
      );

      controlador.agregarLibro(libro);

      if (_tipoEscrituraSeleccionado == 'capitulos') {
        Get.to(() => CrearCapituloPage(libroId: libro.id, tituloLibro: libro.titulo, numeroCapitulo: 1));
      } else {
        Get.back();
      }
    }
  }
}
