import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.edit),
          label: 'Crear',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark),
          label: 'Biblioteca',
        ),
      ],
      onTap: (index) {
        if (index == 0) {
          // Mostrar diálogo para elegir tipo de creación
          _mostrarDialogoCreacion(context);
        } else if (index == 1){
          context.go('/biblioteca');
        }
      },
    );
  }

  void _mostrarDialogoCreacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Qué deseas crear?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('Libro por capítulos'),
              onTap: () {
                Navigator.pop(context);
                context.go('/crear-libro');
                // El tipo se selecciona en la siguiente pantalla
              },
            ),
          ],
        ),
      ),
    );
  }
}