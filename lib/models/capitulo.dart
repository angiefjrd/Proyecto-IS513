class Capitulo {
  final String id;
  final String libroId;
  final String titulo;
  final String contenido;
  final int numero;
  final DateTime fechaPublicacion;

  Capitulo({
    required this.id,
    required this.libroId,
    required this.titulo,
    required this.contenido,
    required this.numero,
    required this.fechaPublicacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'libroId': libroId,
      'titulo': titulo,
      'contenido': contenido,
      'numero': numero,
      'fechaPublicacion': fechaPublicacion.toString(),
    };
  }

  factory Capitulo.fromMap(String id, Map<String, dynamic> map) {
    return Capitulo(
      id: id,
      libroId: map['libroId'] ?? '',
      titulo: map['titulo'] ?? '',
      contenido: map['contenido'] ?? '',
      numero: map['numero'] ?? 0,
      fechaPublicacion: DateTime.parse(map['fechaPublicacion']),
    );
  }
}