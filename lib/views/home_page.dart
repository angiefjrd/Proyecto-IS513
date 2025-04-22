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
    _loadBooks();
  }

  void _loadBooks() {
    _booksFuture = _apiService.fetchBooks(query: 'fiction').catchError((error) {
      debugPrint('Error cargando libros: $error');
      return <Libro>[]; 
    });
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
      body: FutureBuilder<List<Libro>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Error al cargar los libros'),
                  ElevatedButton(
                    onPressed: _loadBooks,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return const Center(child: Text('No hay libros disponibles'));
          }

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
              final book = books[index];
              return LibroCard(
                book: Libro(
                  id: book.id,
                  titulo: book.titulo,
                  autor: book.autor,
                  autorId: book.autorId,
                  descripcion: book.descripcion,
                  portadaUrl: book.portadaUrl,
                  calificacion: book.calificacion,
                  lectores: book.lectores,
                  reacciones: book.reacciones,
                  fechaCreacion: book.fechaCreacion,
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}