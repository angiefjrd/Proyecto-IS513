class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String description;
  final String thumbnail;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.description,
    required this.thumbnail,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};
    return Book(
      id: json['id'] ?? '',
      title: volumeInfo['title'] ?? 'Sin título',
      authors: List<String>.from(volumeInfo['authors'] ?? ['Autor desconocido']),
      description: volumeInfo['description'] ?? 'Sin descripción',
      thumbnail: imageLinks['thumbnail'] ?? '',
    );
  }
}