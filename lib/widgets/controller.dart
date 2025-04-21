import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/libro.dart';
import '../models/arte.dart';
import '../models/comentarios.dart';
import '../models/categorias.dart';

class Controller extends GetxController {  
  final RxList<Libro> libros = <Libro>[].obs;
  final RxList<Arte> obrasArte = <Arte>[].obs;
  final RxString selectedCategory = 'Todos'.obs;
  final RxBool isLoading = false.obs;
  
  final List<String> categorias = Categorias.lista;

  @override
  void onInit() {
    super.onInit();
    cargarLibros();
    cargarObrasArte();
  }
  
  Future<void> cargarLibros() async {
    try {
      isLoading.value = true;
      
      if (FirebaseAuth.instance.currentUser != null) {
        final snapshot = await FirebaseFirestore.instance.collection('libros').get();
        
        final librosData = snapshot.docs.map((doc) {
          final data = doc.data();
          return Libro.fromJson(data);  
        }).toList();
        
        libros.assignAll(librosData);
      } else {
        // Datos de muestra 
        libros.assignAll([
          Libro(
            id: '1',
            titulo: 'El Principito',
            autor: 'Antoine de Saint-Exupéry',
            portadaUrl: 'https://m.media-amazon.com/images/I/71M4Y0U-1VL._AC_UF1000,1000_QL80_.jpg',
            descripcion: 'Un clásico de la literatura infantil que también cautiva a los adultos.',
            calificacion: 4.8,
            lectores: 1200,
            reacciones: ['me gusta', 'increíble', 'fascinante'],
          ),
          Libro(
            id: '2',
            titulo: 'Cien años de soledad',
            autor: 'Gabriel García Márquez',
            portadaUrl: 'https://m.media-amazon.com/images/I/91m6X+JN3VL._AC_UF1000,1000_QL80_.jpg',
            descripcion: 'La obra maestra del realismo mágico que cuenta la historia de la familia Buendía.',
            calificacion: 4.9,
            lectores: 2500,
            reacciones: ['me gusta', 'fascinante'],
          ),
          Libro(
            id: '3',
            titulo: 'Poemas del alma',
            autor: 'Andrea Vázquez',
            portadaUrl: '',
            descripcion: 'Compilación de poemas sobre el amor, la tristeza y la esperanza.',
            calificacion: 4.3,
            lectores: 560,
            reacciones: [],
          ),
        ]);
      }
    } catch (e) {
      print('Error al cargar libros: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> cargarObrasArte() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        final snapshot = await FirebaseFirestore.instance.collection('arte').get();
        
        final arteData = snapshot.docs.map((doc) {
          final data = doc.data();
          return Arte.fromMap(doc.id, data);
        }).toList();
        
        obrasArte.assignAll(arteData);
      } else {
        obrasArte.assignAll([
          Arte(
            id: '1',
            libroId: '1',
            titulo: 'El Principito y la rosa',
            artista: 'María López',
            imagenUrl: 'https://placeholder.com/art1.jpg',
            descripcion: 'Acuarela inspirada en el capítulo de la rosa.',
          ),
          Arte(
            id: '2',
            libroId: '1',
            titulo: 'El zorro del desierto',
            artista: 'Pedro Sánchez',
            imagenUrl: 'https://placeholder.com/art2.jpg',
            descripcion: 'Ilustración del encuentro con el zorro.',
          ),
        ]);
      }
    } catch (e) {
      print('Error al cargar obras de arte: $e');
    }
  }

  List<Libro> getLibrosPorCategoria(String categoria) {
    if (categoria == 'Todos') {
      return libros;
    } else {
      return libros.where((libro) => libro.reacciones.contains(categoria)).toList(); 
    }
  }

  void agregarLibro(Libro libro) {
    if (FirebaseAuth.instance.currentUser != null) {
      
      FirebaseFirestore.instance.collection('libros').add(libro.toJson());  
    }
    libros.add(libro);
  }

  void agregarObraArte(Arte obraArte) {
    if (FirebaseAuth.instance.currentUser != null) {
    
      FirebaseFirestore.instance.collection('arte').add(obraArte.toMap());
    }
    obrasArte.add(obraArte);
  }

  void agregarComentario(String libroId, String textoComentario) async {
    final index = libros.indexWhere((libro) => libro.id == libroId);
    if (index != -1) {
      final libro = libros[index];
      
      final nuevoComentario = Comentario(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        autor: FirebaseAuth.instance.currentUser?.displayName ?? 'Usuario',
        texto: textoComentario,
        fecha: DateTime.now(),
        avatarUrl: FirebaseAuth.instance.currentUser?.photoURL ?? '',
      );
      
      final libroActualizado = libro.copyWith(
        comentarios: [...libro.comentarios, nuevoComentario],
      );
      
      libros[index] = libroActualizado;
      libros.refresh();
      
      if (FirebaseAuth.instance.currentUser != null) {
        FirebaseFirestore.instance
            .collection('libros')
            .doc(libroId)
            .update({'comentarios': FieldValue.arrayUnion([nuevoComentario.toMap()])});
      }
    }
  }
  
  void agregarReaccion(String libroId, String reaccion) async {
    final docRef = FirebaseFirestore.instance.collection('libros').doc(libroId);

    try {
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        
        List<String> reacciones = List<String>.from(docSnapshot['reacciones'] ?? []);

        if (!reacciones.contains(reaccion)) {
          reacciones.add(reaccion);

          await docRef.update({'reacciones': reacciones});
        }
      }
    } catch (e) {
      print("Error al agregar la reacción: $e");
    }
  }
}
