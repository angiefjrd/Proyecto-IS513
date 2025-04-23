import 'package:cloud_firestore/cloud_firestore.dart';

class Arte {
  final String id;
  final String libroId;
  final String titulo;
  final String descripcion;
  final String imagenUrl;
  final String artista;
  final String artistaId;
  final int likes;
  final List<String> likedBy;
  final DateTime fechaCreacion;

  Arte({
    required this.id,
    required this.libroId,
    required this.titulo,
    required this.descripcion,
    required this.imagenUrl,
    required this.artista,
    required this.artistaId,
    this.likes = 0,
    this.likedBy = const [],
    required this.fechaCreacion,
  });

  // Método fromMap
  factory Arte.fromMap(String id, Map<String, dynamic> map) {
  try {
    return Arte(
      id: id,
      libroId: _parseString(map['libroId']),
      titulo: _parseString(map['titulo']),
      descripcion: _parseString(map['descripcion']),
      imagenUrl: _parseString(map['imagenUrl']),
      artista: _parseString(map['artista']),
      artistaId: _parseString(map['artistaId']),
      likes: _parseInt(map['likes']),
      likedBy: _parseStringList(map['likedBy']),
      fechaCreacion: _parseTimestamp(map['fechaCreacion']),
    );
  } catch (e) {
    throw Exception('Error al parsear Arte: $e');
  }
}

// Métodos auxiliares para parseo seguro
static String _parseString(dynamic value) => value?.toString() ?? '';

static int _parseInt(dynamic value) => value is int ? value : int.tryParse(value?.toString() ?? '0') ?? 0;

static List<String> _parseStringList(dynamic value) {
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return [];
}

static DateTime _parseTimestamp(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  return DateTime.now();
}

  // Método toMap
  Map<String, dynamic> toMap() {
    return {
      'libroId': libroId,
      'titulo': titulo,
      'descripcion': descripcion,
      'imagenUrl': imagenUrl,
      'artista': artista,
      'artistaId': artistaId,
      'likes': likes,
      'likedBy': likedBy,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }

  // Añade este método copyWith
  Arte copyWith({
    String? id,
    String? libroId,
    String? titulo,
    String? descripcion,
    String? imagenUrl,
    String? artista,
    String? artistaId,
    int? likes,
    List<String>? likedBy,
    DateTime? fechaCreacion,
  }) {
    return Arte(
      id: id ?? this.id,
      libroId: libroId ?? this.libroId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      artista: artista ?? this.artista,
      artistaId: artistaId ?? this.artistaId,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}