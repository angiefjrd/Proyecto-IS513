class Libro {
  final String id;
  final String titulo;
  final String autor;
  final String portadaUrl;
  final String descripcion;
  final double calificacion;
  final int lectores;
  final List<String> comentarios;
  final List<String> reacciones;

  Libro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.portadaUrl,
    required this.descripcion,
    this.calificacion = 0,
    this.lectores = 0,
    this.comentarios = const [],
    this.reacciones = const [],
  });

  factory Libro.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'] ?? {};
    return Libro(
      id: json['id'] ?? '',
      titulo: volumeInfo['title'] ?? 'Sin título',
      autor: (volumeInfo['authors'] != null && volumeInfo['authors'] is List)
          ? (volumeInfo['authors'] as List).join(', ')
          : 'Autor desconocido',
      descripcion: volumeInfo['description'] ?? 'Sin descripción',
      portadaUrl: imageLinks['thumbnail'] ?? '',
      calificacion: 0,
      lectores: 0,
      comentarios: [],
      reacciones: [],
    );
  }

  // Método copyWith
  Libro copyWith({
    String? id,
    String? titulo,
    String? autor,
    String? portadaUrl,
    String? descripcion,
    double? calificacion,
    int? lectores,
    List<String>? comentarios,
    List<String>? reacciones,
  }) {
    return Libro(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      autor: autor ?? this.autor,
      portadaUrl: portadaUrl ?? this.portadaUrl,
      descripcion: descripcion ?? this.descripcion,
      calificacion: calificacion ?? this.calificacion,
      lectores: lectores ?? this.lectores,
      comentarios: comentarios ?? this.comentarios,
      reacciones: reacciones ?? this.reacciones,
    );
  }

  // Método toMap
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'portadaUrl': portadaUrl,
      'descripcion': descripcion,
      'calificacion': calificacion,
      'lectores': lectores,
      'comentarios': comentarios,
      'reacciones': reacciones,
    };
  }
  
  Map<String, dynamic> toJson() {
    return toMap(); 
  }
}
