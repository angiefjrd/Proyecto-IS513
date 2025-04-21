import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:writerhub/models/libro.dart';
import 'package:writerhub/widgets/botton_nav.dart';
import 'package:writerhub/widgets/logo_text.dart';
import '../widgets/book_card.dart';
import '../services/api_services.dart';
import '../views/perfil_page.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final ApiService _apiService = ApiService();
  late Future<List<Libro>> _booksFuture;

  @override
  void initState() {
    super.initState();
    // Cargar los libros desde la API
    _booksFuture = _apiService.fetchBooks(query: 'fiction'); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const LogoText(),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          },
        icon: const Icon(Icons.account_circle),
        ),
        ],
      ),
        //FirebaseAuth.instance.signOut();
      body: FutureBuilder<List<Libro>>(
        future: _booksFuture, // Cargar los libros
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron libros.'));
          } else {
            final books = snapshot.data!;

            // Si los libros se cargaron correctamente, mostrar el GridView
            return GridView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: books.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                
                return LibroCard(book: books[index]);
              },
            );
          }
        },
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}
