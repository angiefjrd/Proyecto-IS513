import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/libro.dart';
import 'biblioteca_detalle_page.dart'; 

class BibliotecaPage extends StatelessWidget {
  const BibliotecaPage({super.key});

Future<List<Libro>> fetchLibrosGuardados() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];

  final snapshot = await FirebaseFirestore.instance
      .collection('usuarios')
      .doc(user.uid)
      .collection('biblioteca')
      .get();

  return snapshot.docs.map((doc) {
    final data = doc.data();
    return Libro(
      id: data['libroId'] ?? '',
      titulo: data['titulo'] ?? '',
      autor: data['autor'] ?? '',
      portadaUrl: data['portadaUrl'] ?? '',
      descripcion: '', 
      autorId: '',      
      fechaCreacion: null, 
      genres: [],       
      capitulos: [],    
      ultimaActualizacion: DateTime.now(), 
      vistas: 0,
    );
  }).toList();
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tu Biblioteca')),
      body: FutureBuilder<List<Libro>>(
        future: fetchLibrosGuardados(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar biblioteca'));
          }
          final libros = snapshot.data ?? [];

          if (libros.isEmpty) {
            return const Center(child: Text('No tienes libros guardados.'));
          }

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: libros.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.6,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final libro = libros[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BibliotecaDetallePage(libro: libro),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: libro.portadaUrl.isNotEmpty
                                ? Image.network(libro.portadaUrl, fit: BoxFit.cover)
                                : Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.book, size: 60),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Column(
                            children: [
                              Text(libro.titulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(libro.autor, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
