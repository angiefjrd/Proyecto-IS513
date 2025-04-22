import 'package:flutter/material.dart'; // Add this import
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:writerhub/views/lecturalib.dart';
import '../views/home_page.dart';
import '../views/login_page.dart';
import '../views/signup_page.dart';
import '../views/perfil_page.dart';
import '../views/detalles_libro.dart';
import '../views/agregar_libro.dart';
import '../views/arte_pantalla.dart';
import '../views/galeria.dart';
import '../views/detalle_page.dart';
import '../views/crear_libro.dart';
import '../views/crear_capitulo.dart';
import '../views/lecturacap.dart';
import '../views/lecturalib.dart';
import '../models/arte.dart';
import '../models/libro.dart';

class Rutas {
  static GoRouter configurarRutas(User? usuario) {
    final estaLogueado = usuario != null;

    return GoRouter(
      initialLocation: estaLogueado ? '/' : '/login',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
          routes: [
            GoRoute(
              path: 'libro/:id',
              builder: (context, state) => DetalleLibroPage(
                libroId: state.pathParameters['id']!,
              ),
            ),
            GoRoute(
              path: 'agregar-libro',
              builder: (context, state) => const AgregarLibro(),
            ),
            GoRoute(
              path: 'crear-libro',
              builder: (context, state) => const CrearLibroPage(),
            ),
            GoRoute(
              path: 'arte/:libroId',
              builder: (context, state) => ArtePantalla(
                libroId: state.pathParameters['libroId']!,
              ),
            ),
            GoRoute(
              path: 'agregar-arte/:libroId',
              builder: (context, state) => Galeria(
                arte: Arte(
                  id: '',
                  libroId: state.pathParameters['libroId']!,
                  titulo: '',
                  artista: '',
                  imagenUrl: '',
                  descripcion: '',
                ),
              ),
            ),
            GoRoute(
              path: 'crear-capitulo/:libroId/:numero',
              builder: (context, state) => CrearCapituloPage(
                libroId: state.pathParameters['libroId']!,
                numeroCapitulo: int.parse(state.pathParameters['numero']!),
                tituloLibro: state.pathParameters['tituloLibro']!,
              ),
            ),
            GoRoute(
              path: 'leer-capitulos/:libroId',
              builder: (context, state) => LecturaCapitulosPage(
                libro: state.extra as Libro,
              ),
            ),
            GoRoute(
              path: 'leer-libro/:libroId',
              builder: (context, state) => LecturaLibroPage(
                libro: state.extra as Libro,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpPage(),
        ),
      ],
      redirect: (BuildContext context, GoRouterState state) {
        final usuario = FirebaseAuth.instance.currentUser;
        final path = state.uri.path;

        final estaEnLogin = path == '/login' || path == '/signup';

        if (usuario == null && !estaEnLogin) {
          return '/login';
        } else if (usuario != null && estaEnLogin) {
          return '/';
        }

        return null;
      },
    );
  }
}