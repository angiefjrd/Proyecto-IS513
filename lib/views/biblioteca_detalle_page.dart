import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:writerhub/models/libro.dart';

class BibliotecaDetallePage extends StatelessWidget {
  final Libro libro;

  const BibliotecaDetallePage({super.key, required this.libro});

  Future<List<Map<String, dynamic>>> fetchCapitulos() async {
    final libroRef = FirebaseFirestore.instance.collection('libros').doc(libro.id);

    // Verifica si el documento del libro existe
    final docSnapshot = await libroRef.get();
    if (!docSnapshot.exists) {
      throw Exception('El libro no existe en Firestore.');
    }

    // Obtiene los capítulos
    final snapshot = await libroRef.collection('capitulos').get();

    // Si no hay capítulos, retorna una lista vacía
    if (snapshot.docs.isEmpty) {
      return [];
    }

    // Devuelve la lista de capítulos como Map<String, dynamic>
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
            return Center(child: Text('Error al cargar capítulos: ${snapshot.error}'));
          }

          final capitulos = snapshot.data ?? [];

          if (capitulos.isEmpty) {
            return const Center(child: Text('Este libro no tiene capítulos.'));
          }

          return ListView.builder(
            itemCount: capitulos.length,
            itemBuilder: (context, index) {
              final cap = capitulos[index];
              final nombre = cap['nombre'] as String? ?? 'Capítulo ${index + 1}';
              final contenido = cap['contenido'] as String? ?? 'Contenido no disponible';

              return ExpansionTile(
                title: Text(nombre),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(contenido),
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


