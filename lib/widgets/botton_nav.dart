import 'package:flutter/material.dart';

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
          Navigator.pushNamed(context, '/create');
        } else {
          Navigator.pushNamed(context, '/library');
        }
      },
    );
  }
}