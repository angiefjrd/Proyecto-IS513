import 'package:writerhub/models/comentarios.dart';

class Libro {
  final String id;
  final String titulo;
  final String autor;
  final String portadaUrl;
  final String descripcion;
  final double calificacion;
  final int lectores;
  final List<String> reacciones; 
  final List<Comentario> comentarios;

  Libro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.portadaUrl,
    required this.descripcion,
    required this.calificacion,
    required this.lectores,
    required this.reacciones,
    this.comentarios = const [],
  });

  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      autor: json['autor'] ?? '',
      portadaUrl: json['portadaUrl'] ?? '',
      descripcion: json['descripcion'] ?? '',
      calificacion: (json['calificacion'] ?? 0).toDouble(),
      lectores: json['lectores'] ?? 0,
      reacciones: List<String>.from(json['reacciones'] ?? []),
      comentarios: (json['comentarios'] as List<dynamic>? ?? [])
          .map((item) => Comentario.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'portadaUrl': portadaUrl,
      'descripcion': descripcion,
      'calificacion': calificacion,
      'lectores': lectores,
      'reacciones': reacciones,
      'comentarios': comentarios.map((c) => c.toMap()).toList(),
    };
  }

  Libro copyWith({String? id, String? titulo, String? autor, String? portadaUrl, String? descripcion, double? calificacion, int? lectores, List<String>? reacciones, List<Comentario>? comentarios}) {
    return Libro(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      autor: autor ?? this.autor,
      portadaUrl: portadaUrl ?? this.portadaUrl,
      descripcion: descripcion ?? this.descripcion,
      calificacion: calificacion ?? this.calificacion,
      lectores: lectores ?? this.lectores,
      reacciones: reacciones ?? this.reacciones,
      comentarios: comentarios ?? this.comentarios,
    );
  }
}

