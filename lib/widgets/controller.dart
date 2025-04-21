import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/libro.dart';
import '../models/arte.dart';
import '../models/comentarios.dart';
import '../models/capitulo.dart';
import '../models/categorias.dart';

class Controller extends GetxController {  
  final RxList<Libro> libros = <Libro>[].obs;
  final RxList<Arte> obrasArte = <Arte>[].obs;
  final RxList<Capitulo> capitulos = <Capitulo>[].obs;
  final RxString selectedCategory = 'Todos'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxInt capituloActual = 1.obs; 
  final RxMap<String, int> ultimoCapituloLeido = <String, int>{}.obs;
  
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
      libros.clear();
      
      final snapshot = await FirebaseFirestore.instance
          .collection('libros')
          .orderBy('fechaCreacion', descending: true)
          .get();
      
      libros.assignAll(
        snapshot.docs.map((doc) => Libro.fromJson(doc.data())),
      );
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los libros');
      print('Error al cargar libros: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> cargarCapitulos(String libroId) async {
    try {
      isLoading.value = true;
      capitulos.clear();
      
      final snapshot = await FirebaseFirestore.instance
          .collection('capitulos')
          .where('libroId', isEqualTo: libroId)
          .orderBy('numero')
          .get();
          
      capitulos.assignAll(
        snapshot.docs.map((doc) => Capitulo.fromMap(doc.id, doc.data())),
      );
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los capítulos');
      print('Error al cargar capítulos: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> agregarLibro(Libro libro) async {
    try {
      isSaving.value = true;
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        libro.autorId = user.uid;
        if (libro.autor.isEmpty) {
          libro.autor = user.displayName ?? 'Anónimo';
        }
        
        await FirebaseFirestore.instance
            .collection('libros')
            .add(libro.toJson());
            
        libros.insert(0, libro);
        Get.snackbar('Éxito', 'Libro creado correctamente');
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo crear el libro');
      print('Error al agregar libro: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> agregarCapitulo(Capitulo capitulo) async {
    try {
      isSaving.value = true;
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        // Verificar que el usuario es el autor del libro
        final libroDoc = await FirebaseFirestore.instance
            .collection('libros')
            .doc(capitulo.libroId)
            .get();
            
        if (libroDoc.exists && libroDoc.data()?['autorId'] == user.uid) {
          await FirebaseFirestore.instance
              .collection('capitulos')
              .add(capitulo.toMap());
              
          capitulos.add(capitulo);
          Get.snackbar('Éxito', 'Capítulo publicado');
        } else {
          throw 'No tienes permiso para añadir capítulos';
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo publicar el capítulo');
      print('Error al agregar capítulo: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> agregarComentario(String libroId, String textoComentario) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final nuevoComentario = Comentario(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        autor: user.displayName ?? 'Anónimo',
        texto: textoComentario,
        fecha: DateTime.now(),
        avatarUrl: user.photoURL ?? '',
      );
      
      await FirebaseFirestore.instance
          .collection('libros')
          .doc(libroId)
          .update({
            'comentarios': FieldValue.arrayUnion([nuevoComentario.toMap()])
          });
          
      final index = libros.indexWhere((l) => l.id == libroId);
      if (index != -1) {
        final libro = libros[index];
        libros[index] = libro.copyWith(
          comentarios: [...libro.comentarios, nuevoComentario],
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo agregar el comentario');
      print('Error al agregar comentario: $e');
    }
  }
  
  Future<void> agregarReaccion(String libroId, String reaccion) async {
    try {
      final libroRef = FirebaseFirestore.instance.collection('libros').doc(libroId);
      
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(libroRef);
        if (!snapshot.exists) return;
        
        final reacciones = List<String>.from(snapshot['reacciones'] ?? []);
        if (!reacciones.contains(reaccion)) {
          reacciones.add(reaccion);
          transaction.update(libroRef, {'reacciones': reacciones});
        }
      });
      
      final index = libros.indexWhere((l) => l.id == libroId);
      if (index != -1) {
        final libro = libros[index];
        if (!libro.reacciones.contains(reaccion)) {
          libros[index] = libro.copyWith(
            reacciones: [...libro.reacciones, reaccion],
          );
        }
      }
    } catch (e) {
      print('Error al agregar reacción: $e');
    }
  }

  List<Libro> getLibrosPorCategoria(String categoria) {
    if (categoria == 'Todos') return libros;
    return libros.where((l) => l.reacciones.contains(categoria)).toList();
  }

  Future<void> cargarObrasArte() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('arte').get();
      obrasArte.assignAll(
        snapshot.docs.map((doc) => Arte.fromMap(doc.id, doc.data())),
      );
    } catch (e) {
      print('Error al cargar obras de arte: $e');
    }
  }

  Future<void> agregarObraArte(Arte obraArte) async {
    try {
      await FirebaseFirestore.instance.collection('arte').add(obraArte.toMap());
      obrasArte.add(obraArte);
    } catch (e) {
      print('Error al agregar obra de arte: $e');
    }
  }
}