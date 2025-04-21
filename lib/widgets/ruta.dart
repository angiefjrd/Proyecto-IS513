import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/home_page.dart';
import '../views/login_page.dart';
import '../views/signup_page.dart';
import '../views/perfil_page.dart';
import '../views/detalles_libro.dart';
import '../views/agregar_libro.dart';
import '../views/arte_pantalla.dart';
import '../views/galeria.dart';
import '../views/detalle_page.dart';
import '../models/arte.dart';

class Rutas {
  static GoRouter configurarRutas(User? usuario) {
    final estaLogueado = usuario != null;

    return GoRouter(
      initialLocation: estaLogueado ? '/' : '/login',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MyHomePage(),
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
              path: 'perfil',
              builder: (context, state) => const PerfilPage(),
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
    );
  }
}