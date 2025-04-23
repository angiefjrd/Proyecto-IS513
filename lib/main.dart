import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'widgets/ruta.dart';
import 'widgets/controller.dart';
import 'tema/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Get.put(Controller());
    await corregirNombreCampo();
    runApp(const MyApp());
  } catch (e) {
    print('Error initializing Firebase: $e');
    runApp(const ErrorApp());
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error initializing app: Please try again later'),
        ),
      ),
    );
  }
}

Future<void> corregirNombreCampo() async {
  try {
    final librosRef = FirebaseFirestore.instance.collection('libros');
    final snapshot = await librosRef.get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data.containsKey('fecha de actualizacion')) {
        await librosRef.doc(doc.id).update({
          'ultimaActualizacion': data['fecha de actualizacion'],
          'fecha de actualizacion': FieldValue.delete(),
        });
      }
    }
  } catch (e) {
    print('Error corrigiendo nombres de campo: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'WriterHub',
          theme: appTheme,
          routerConfig: Rutas.configurarRutas(snapshot.data),
        );
      },
    );
  }
}