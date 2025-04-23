import 'dart:io';

class Arte {
  final String id;
  final String libroId;
  final String titulo;
  final String artista;
  final String artistaId;
  final String imagenUrl;
  final String descripcion;
  final DateTime fechaCreacion;
  final List<String> etiquetas;
  final int likes;
  final List<String> likedBy;
  File? imagenFile; 
  bool get isUploading => imagenFile != null && imagenUrl.isEmpty;

  Arte({
    required this.id,
    required this.libroId,
    required this.titulo,
    required this.artista,
    required this.artistaId,
    required this.imagenUrl,
    required this.descripcion,
    required this.fechaCreacion,
    this.etiquetas = const [],
    this.likes = 0,
    this.likedBy = const [],
  });

  factory Arte.fromMap(String id, Map<String, dynamic> map) {
    return Arte(
      id: id,
      libroId: map['libroId'] ?? '',
      titulo: map['titulo'] ?? '',
      artista: map['artista'] ?? '',
      artistaId: map['artistaId'] ?? '',
      imagenUrl: map['imagenUrl'] ?? '',
      descripcion: map['descripcion'] ?? '',
      fechaCreacion: map['fechaCreacion'] != null 
          ? DateTime.parse(map['fechaCreacion'])
          : DateTime.now(),
      etiquetas: List<String>.from(map['etiquetas'] ?? []),
      likes: map['likes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'libroId': libroId,
      'titulo': titulo,
      'artista': artista,
      'artistaId': artistaId,
      'imagenUrl': imagenUrl,
      'descripcion': descripcion,
      'fechaCreacion': fechaCreacion.toIso8601String(),
      'etiquetas': etiquetas,
      'likes': likes,
    };
  }

  Arte copyWith({
    String? titulo,
    String? descripcion,
    List<String>? etiquetas,
    int? likes,
  }) {
    return Arte(
      id: id,
      libroId: libroId,
      titulo: titulo ?? this.titulo,
      artista: artista,
      artistaId: artistaId,
      imagenUrl: imagenUrl,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion,
      etiquetas: etiquetas ?? this.etiquetas,
      likes: likes ?? this.likes,
    );
  }
}