class Comentario {
  final String id;
  final String autor;
  final String texto;
  final DateTime fecha;
  final String avatarUrl;

  Comentario({
    required this.id,
    required this.autor,
    required this.texto,
    required this.fecha,
    this.avatarUrl = '',
  });

  String fechaFormateada() {
    return "${fecha.day}/${fecha.month}/${fecha.year}";
  }
}