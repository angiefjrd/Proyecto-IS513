class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String thumbnail;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.thumbnail,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};
    return Book(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? 'Sin título',
      author: (volumeInfo['authors'] != null && volumeInfo['authors'] is List)
          ? (volumeInfo['authors'] as List).join(', ')
          : 'Autor desconocido',
      description: volumeInfo['description'] ?? 'Sin descripción',
      thumbnail: imageLinks['thumbnail'] ?? '',
    );
  }
}