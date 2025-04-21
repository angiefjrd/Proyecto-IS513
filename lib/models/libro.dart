import 'package:writerhub/models/comentarios.dart';

class Libro {
  final String id;
  final String titulo;
  String autor;  
  String autorId;
  final String portadaUrl;
  final String descripcion;
  final String? contenidoCompleto;
  final bool esEnEmision;
  final double calificacion;
  final int lectores;
  final List<String> reacciones;
  final List<Comentario> comentarios;
  final DateTime fechaCreacion;

  Libro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.autorId,
    required this.portadaUrl,
    required this.descripcion,
    this.contenidoCompleto,
    this.esEnEmision = false,
    this.calificacion = 0,
    this.lectores = 0,
    this.reacciones = const [],
    this.comentarios = const [],
    required this.fechaCreacion,
  });

  // Método factory para crear instancia desde JSON
  factory Libro.fromJson(Map<String, dynamic> json) {
    return Libro(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      autor: json['autor'] ?? '',
      autorId: json['autorId'] ?? '',
      portadaUrl: json['portadaUrl'] ?? '',
      descripcion: json['descripcion'] ?? '',
      contenidoCompleto: json['contenidoCompleto'],
      esEnEmision: json['esEnEmision'] ?? false,
      calificacion: (json['calificacion'] ?? 0).toDouble(),
      lectores: json['lectores'] ?? 0,
      reacciones: List<String>.from(json['reacciones'] ?? []),
      comentarios: (json['comentarios'] as List<dynamic>? ?? [])
          .map((item) => Comentario.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'autorId': autorId,
      'portadaUrl': portadaUrl,
      'descripcion': descripcion,
      'contenidoCompleto': contenidoCompleto,
      'esEnEmision': esEnEmision,
      'calificacion': calificacion,
      'lectores': lectores,
      'reacciones': reacciones,
      'comentarios': comentarios.map((c) => c.toMap()).toList(),
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  Libro copyWith({
    String? id,
    String? titulo,
    String? autor,
    String? autorId,
    String? portadaUrl,
    String? descripcion,
    String? contenidoCompleto,
    bool? esEnEmision,
    double? calificacion,
    int? lectores,
    List<String>? reacciones,
    List<Comentario>? comentarios,
    DateTime? fechaCreacion,
  }) {
    return Libro(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      autor: autor ?? this.autor,
      autorId: autorId ?? this.autorId,
      portadaUrl: portadaUrl ?? this.portadaUrl,
      descripcion: descripcion ?? this.descripcion,
      contenidoCompleto: contenidoCompleto ?? this.contenidoCompleto,
      esEnEmision: esEnEmision ?? this.esEnEmision,
      calificacion: calificacion ?? this.calificacion,
      lectores: lectores ?? this.lectores,
      reacciones: reacciones ?? this.reacciones,
      comentarios: comentarios ?? this.comentarios,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}