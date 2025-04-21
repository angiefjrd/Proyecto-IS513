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
}