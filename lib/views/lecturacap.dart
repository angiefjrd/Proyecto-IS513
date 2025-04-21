import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:writerhub/models/libro.dart';
import 'package:writerhub/widgets/controller.dart';
import 'crear_capitulo.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LecturaCapitulosPage extends StatefulWidget {
  final Libro libro;
  final int capituloInicial;

  const LecturaCapitulosPage({
    super.key, 
    required this.libro,
    this.capituloInicial = 1,
  });

  @override
  State<LecturaCapitulosPage> createState() => _LecturaCapitulosPageState();
}

class _LecturaCapitulosPageState extends State<LecturaCapitulosPage> {
  final Controller _controller = Get.find();
  late int _capituloActual;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _capituloActual = widget.capituloInicial;
    _controller.cargarCapitulos(widget.libro.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.libro.titulo),
        actions: [
          if (FirebaseAuth.instance.currentUser?.uid == widget.libro.autorId)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                final nextChapter = _controller.capitulos.isEmpty 
                    ? 1 
                    : _controller.capitulos.last.numero + 1;
                Get.to(() => CrearCapituloPage(
                  libroId: widget.libro.id,
                  numeroCapitulo: nextChapter,
                ))?.then((_) => _controller.cargarCapitulos(widget.libro.id));
              },
            ),
        ],
      ),
      body: Obx(() {
        if (_controller.capitulos.isEmpty) {
          return const Center(
            child: Text('Aún no hay capítulos publicados para este libro'),
          );
        }
        
        final capitulo = _controller.capitulos.firstWhere(
          (c) => c.numero == _capituloActual,
          orElse: () {
            // If requested chapter doesn't exist, default to first chapter
            _capituloActual = _controller.capitulos.first.numero;
            return _controller.capitulos.first;
          },
        );
        
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Capítulo ${capitulo.numero}: ${capitulo.titulo}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Publicado el ${_formatearFecha(capitulo.fechaPublicacion)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      capitulo.contenido,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
            if (_controller.capitulos.length > 1) _buildBottomNavBar(),
          ],
        );
      }),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _capituloActual > 1
                ? () {
                    setState(() => _capituloActual--);
                    _scrollController.jumpTo(0);
                    _controller.ultimoCapituloLeido[widget.libro.id] = _capituloActual;
                  }
                : null,
          ),
          Text('Capítulo $_capituloActual/${_controller.capitulos.length}'),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _capituloActual < _controller.capitulos.length
                ? () {
                    setState(() => _capituloActual++);
                    _scrollController.jumpTo(0);
                    _controller.ultimoCapituloLeido[widget.libro.id] = _capituloActual;
                  }
                : null,
          ),
        ],
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}