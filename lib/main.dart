import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'widgets/ruta.dart';
import 'widgets/controller.dart';
import 'tema/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializa GetX controller
  Get.put(Controller());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Manejamos el estado de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // O alguna pantalla de carga
        }

        // Configuración del router con validación de datos del usuario
        return GetMaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'WriterHub',
          theme: appTheme,
          routerConfig: Rutas.configurarRutas(snapshot.data), // Aquí se pasa snapshot.data
        );
      },
    );
  }
}
