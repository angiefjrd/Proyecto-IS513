import 'package:writerhub/models/comentarios.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String? archivoUrl; // Opcional
  String? nombreArchivo; // Opcional
  List<String>? capitulos; // Opcional
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
    this.archivoUrl, // Opcional
    this.nombreArchivo, // Opcional
    this.etiquetas = const [],
    required this.vistas,
  });

  factory Libro.fromJson(Map<String, dynamic> json, String docID) {
    DateTime parseFecha(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return Libro(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo']?.toString() ?? '',
      autor: json['autor']?.toString() ?? '',
      autorId: json['autorId']?.toString() ?? '',
      portadaUrl: json['portadaUrl']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      contenidoCompleto: json['contenidoCompleto']?.toString(),
      esEnEmision: json['esEnEmision'] ?? false,
      calificacion: (json['calificacion'] ?? 0).toDouble(),
      lectores: json['lectores'] ?? 0,
      reacciones: List<String>.from(json['reacciones'] ?? []),
      comentarios: (json['comentarios'] as List<dynamic>? ?? [])
          .map((item) => Comentario.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      fechaCreacion: parseFecha(json['fechaCreacion']),
      ultimaActualizacion: parseFecha(json['ultimaActualizacion']),
      genres: List<String>.from(json['genres'] ?? []),
      capitulos: (json['capitulos'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      archivoUrl: json['archivoUrl']?.toString(), // Opcional
      nombreArchivo: json['nombreArchivo']?.toString(), // Opcional
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
      'archivoUrl': archivoUrl, // Opcional
      'nombreArchivo': nombreArchivo, // Opcional
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
    String? archivoUrl,
    String? nombreArchivo,
  }) {
    return Libro(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
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
      archivoUrl: archivoUrl ?? this.archivoUrl, 
      nombreArchivo: nombreArchivo ?? this.nombreArchivo, 
    );
  }
}
