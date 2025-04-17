import 'package:flutter/material.dart';
import 'package:writerhub/models/book.dart';
import '../views/detalle_page.dart';

class BookCard extends StatelessWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Asegúrate de que el book se pasa correctamente
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPage(book: book), // Pasando el book aquí
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            book.thumbnail.isNotEmpty
                ? Image.network(
                    book.thumbnail,
                    fit: BoxFit.cover,
                    height: 150,
                    width: double.infinity,
                  )
                : const Placeholder(fallbackHeight: 150), // Usar un Placeholder si no hay imagen
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                book.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                'by ${book.author}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
