class Arte {
  final String id;
  final String libroId;
  final String titulo;
  final String artista;
  final String imagenUrl;
  final String descripcion;

  Arte({
    required this.id,
    required this.libroId,
    required this.titulo,
    required this.artista,
    required this.imagenUrl,
    required this.descripcion,
  });

  factory Arte.fromMap(String id, Map<String, dynamic> map) {
    return Arte(
      id: id,
      libroId: map['libroId'] ?? '',
      titulo: map['titulo'] ?? '',
      artista: map['artista'] ?? '',
      imagenUrl: map['imagenUrl'] ?? '',
      descripcion: map['descripcion'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'libroId': libroId,
      'titulo': titulo,
      'artista': artista,
      'imagenUrl': imagenUrl,
      'descripcion': descripcion,
    };
  }
}
