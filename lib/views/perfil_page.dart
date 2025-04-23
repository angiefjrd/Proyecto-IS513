import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:writerhub/views/detalle_page.dart';
import 'package:writerhub/models/libro.dart';

/// MODELO DEL LIBRO CREADO
// class LibroCreado {
//   final String id;
//   final String titulo;
//   final String portadaUrl;

//   LibroCreado({
//     required this.id,
//     required this.titulo,
//     required this.portadaUrl,
//   });

//   factory LibroCreado.fromMap(Map<String, dynamic> data, String docId) {
//     return LibroCreado(
//       id: docId,
//       titulo: data['titulo'] ?? 'Sin título',
//       portadaUrl: data['portadaUrl'] ?? '',
//     );
//   }
// }


class FirebaseServices {
  Stream<List<Libro>> getCreatedBooks() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('libros')
        .where('autorId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Libro.fromJson(doc.data(), doc.id))
            .toList());
  }
}

/// UI DE LA PÁGINA DE PERFIL
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final photoUrl = user.photoURL;
    final displayName = user.displayName ?? 'Sin nombre';
    final email = user.email ?? 'Sin correo';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //foto
            CircleAvatar(
              radius: 50,
              backgroundImage:
                  photoUrl != null ? NetworkImage(photoUrl) : null,
              child: photoUrl == null
                  ? const Icon(Icons.person, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),

            //nombre
            Text(
              displayName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            /// correo
            Text(
              email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tus libros creados',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            //libros creados
            StreamBuilder<List<Libro>>(
              stream: FirebaseServices().getCreatedBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No has creado libros aún.'));
                }

                final libros = snapshot.data!;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: libros.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) {
                    final libro = libros[index];
                    
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: InkWell(
                        onTap: () {                          
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookDetailPage(libro: libros[index]),
                                ),
                              );                            
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10)),
                                child: libro.portadaUrl.isNotEmpty
                                    ? Image.network(libro.portadaUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity)
                                    : const Icon(Icons.book, size: 80),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),                          
                              child: Text(libro.titulo,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 30),

            
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pop(context); // Regresa al home u otra pantalla
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}





