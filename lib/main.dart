import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'widgets/ruta.dart';
import 'widgets/controller.dart';
import 'tema/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  
  Get.put(Controller());
  await corregirNombreCampo();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); 
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

Future<void> corregirNombreCampo() async {
  final librosRef = FirebaseFirestore.instance.collection('libros');
  final snapshot = await librosRef.get();

  for (var doc in snapshot.docs) {
    final data = doc.data();

    if (data.containsKey('fecha de actualizacion')) {
      final valor = data['fecha de actualizacion'];

      await librosRef.doc(doc.id).update({
        'ultimaActualizacion': valor,
        'fecha de actualizacion': FieldValue.delete(),
      });

      print('✅ Documento ${doc.id} corregido.');
    }
  }

  print('🎉 Todos los campos han sido corregidos.');
}

