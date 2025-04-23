import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:writerhub/models/categorias.dart';
import 'package:writerhub/models/libro.dart';
import 'package:writerhub/widgets/botton_nav.dart';
import 'package:writerhub/widgets/logo_text.dart';
import '../widgets/book_card.dart';
import '../views/perfil_page.dart';


class LibroCard extends StatelessWidget {
  final Libro book;

  const LibroCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: book.portadaUrl.isNotEmpty
                  ? Image.network(
                      book.portadaUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported, size: 40),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(Icons.book, size: 40),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            book.titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            book.autor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<Map<String, List<Libro>>> _groupedBooksFuture;

  @override
  void initState() {
    super.initState();
    _groupedBooksFuture = fetchAndGroupBooks();
  }

  Future<List<Libro>> fetchBooksFromFirebase() async {
    final snapshot = await FirebaseFirestore.instance.collection('libros').get();
    return snapshot.docs.map((doc) => Libro.fromJson(doc.data())).toList();
  }

  Map<String, List<Libro>> groupBooksByGenre(List<Libro> books) {
    final Map<String, List<Libro>> grouped = {};

    for (final book in books) {
      final genres = (book as dynamic).genres ?? []; // if you added genres to your model

      for (final genre in genres) {
        if (!grouped.containsKey(genre)) {
          grouped[genre] = [];
        }
        grouped[genre]!.add(book);
      }
    }

    return grouped;
  }

  Future<Map<String, List<Libro>>> fetchAndGroupBooks() async {
    final books = await fetchBooksFromFirebase();
    return groupBooksByGenre(books);
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
      body: FutureBuilder<Map<String, List<Libro>>>(
        future: _groupedBooksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No se encontraron libros.'));
          }

          final groupedBooks = snapshot.data!;

          return ListView(
            children: groupedBooks.entries.map((entry) {
              final genre = entry.key;
              final books = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      genre[0].toUpperCase() + genre.substring(1), // Capitalize
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: LibroCard(book: books[index]),
                        );
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}

