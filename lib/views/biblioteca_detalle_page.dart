import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:writerhub/models/libro.dart';

class BibliotecaDetallePage extends StatelessWidget {
  final Libro libro;

  const BibliotecaDetallePage({super.key, required this.libro});

  Future<List<Map<String, dynamic>>> fetchCapitulos() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('libros')
        .doc(libro.id)
        .collection('capitulos')
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(libro.titulo),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchCapitulos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar capítulos'));
          }

          final capitulos = snapshot.data ?? [];

          if (capitulos.isEmpty) {
            return const Center(child: Text('Este libro no tiene capítulos.'));
          }

          return ListView.builder(
            itemCount: capitulos.length,
            itemBuilder: (context, index) {
              final cap = capitulos[index];
              return ExpansionTile(
                title: Text(cap['nombre'] ?? 'Capítulo ${index + 1}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(cap['contenido'] ?? 'Sin contenido'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
