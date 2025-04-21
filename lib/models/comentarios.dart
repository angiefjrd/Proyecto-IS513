class Comentario {
  final String id;
  final String autor;
  final String texto;
  final DateTime fecha;
  final String avatarUrl; // Nuevo campo para la imagen de perfil

  Comentario({
    required this.id,
    required this.autor,
    required this.texto,
    required this.fecha,
    this.avatarUrl = '',
  });
}