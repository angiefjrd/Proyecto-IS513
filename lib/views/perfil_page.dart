import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.black,
        child: Column(
          children: [
            const SizedBox(height: 30),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple.shade200,
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              user?.email ?? 'Usuario Anónimo',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

