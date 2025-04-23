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
  final List<String> genres;
  final DateTime ultimaActualizacion;
  String? archivoUrl;
  String? nombreArchivo;
  List<String>? capitulos;
  final int vistas;
  final List<String> etiquetas;

  Libro({
    this.capitulos,
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
    required this.genres,
    required this.ultimaActualizacion,
    this.archivoUrl,
    this.nombreArchivo,
    this.etiquetas = const [],
    required this.vistas,

  });

  
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
      genres: List<String>.from(json['genres'] ?? []),
      ultimaActualizacion: DateTime.parse(json['ultimaActualizacion']),
      vistas: json['vistas'] ?? 0,
      etiquetas: List<String>.from(json['etiquetas'] ?? []),

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
      'fechaCreacion': fechaCreacion.toString(),
      'genres': genres, 
      'ultimaActualizacion': ultimaActualizacion.toString(),
      'capitulos': capitulos,
      'vistas': vistas,
      'etiquetas': etiquetas,
    };
  }

  Libro copyWith({
    String? id,
    String? titulo,
    DateTime? ultimaActualizacion,
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
    List<String>? genres,
    int? vistas,

  }) {
    return Libro(
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
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
      genres: genres ?? this.genres,
       vistas: vistas ?? this.vistas,

    );
  }
}