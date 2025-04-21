import 'package:get/get.dart';
import '../models/libro.dart';
import '../models/arte.dart';

class Controller extends GetxController {  
  final RxList<Libro> libros = <Libro>[].obs;
  final RxList<Arte> obrasArte = <Arte>[].obs;

  @override
  void onInit() {
    super.onInit();

    libros.addAll([
      Libro(
        id: '1',
        titulo: 'El Principito',
        autor: 'Antoine de Saint-Exupéry',
        portadaUrl: 'https://m.media-amazon.com/images/I/71M4Y0U-1VL._AC_UF1000,1000_QL80_.jpg',
        descripcion: 'Un clásico de la literatura infantil y para adultos.',
        calificacion: 4.8,
        lectores: 1200,
        comentarios: [],
        reacciones: [],
      ),
      Libro(
        id: '2',
        titulo: 'Cien años de soledad',
        autor: 'Gabriel García Márquez',
        portadaUrl: 'https://m.media-amazon.com/images/I/91m6X+JN3VL._AC_UF1000,1000_QL80_.jpg',
        descripcion: 'La obra maestra del realismo mágico.',
        calificacion: 4.9,
        lectores: 2500,
        comentarios: [],
        reacciones: [],
      ),
    ]);

    obrasArte.addAll([
      Arte(
        id: '1',
        libroId: '1',
        titulo: 'El Principito y la rosa',
        artista: 'María López',
        imagenUrl: 'https://example.com/art1.jpg',
        descripcion: 'Acuarela inspirada en el capítulo 21',
      ),
    ]);
  }

  void agregarLibro(Libro libro) {
    libros.add(libro);
  }

  void agregarObraArte(Arte obraArte) {
    obrasArte.add(obraArte);
  }

  void agregarComentario(String libroId, String comentario) {
    final index = libros.indexWhere((libro) => libro.id == libroId);
    if (index != -1) {
      final libroActualizado = Libro(
        id: libros[index].id,
        titulo: libros[index].titulo,
        autor: libros[index].autor,
        portadaUrl: libros[index].portadaUrl,
        descripcion: libros[index].descripcion,
        calificacion: libros[index].calificacion,
        lectores: libros[index].lectores,
        comentarios: [...libros[index].comentarios, comentario],
        reacciones: libros[index].reacciones,
      );
      libros[index] = libroActualizado;
      libros.refresh();
    }
  }
}
