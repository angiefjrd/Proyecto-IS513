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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'autor': autor,
      'texto': texto,
      'fecha': fecha.toString(),
      'avatarUrl': avatarUrl,
    };
  }

  factory Comentario.fromMap(Map<String, dynamic> map) {
    return Comentario(
      id: map['id'] ?? '',
      autor: map['autor'] ?? '',
      texto: map['texto'] ?? '',
      fecha: DateTime.parse(map['fecha']),
      avatarUrl: map['avatarUrl'] ?? '',
    );
  }
}
