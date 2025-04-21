import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/home_page.dart';
import '../views/login_page.dart';
import '../views/detalles_libro.dart';
import '../views/agregar_libro.dart';
import '../views/arte_pantalla.dart';

GoRouter rutas(User? user) {
  final estaLogueado = user != null;

  return GoRouter(
    initialLocation: estaLogueado ? '/' : '/login',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MyHomePage(),
        routes: [
          GoRoute(
            path: 'libro/:id',
            builder: (context, state) => DetallesLibro(
              libroId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'agregar-libro',
            builder: (context, state) => const AgregarLibroPantalla(),
          ),
          GoRoute(
            path: 'arte/:libroId',
            builder: (context, state) => ArtePantalla(
              libroId: state.pathParameters['libroId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
    ],
  );
}

