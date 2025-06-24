import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// =========================================================================
// IMPORTACIONES DE TU PROYECTO
// Asegúrate de que todas estas rutas sean correctas según tu estructura de carpetas.
// =========================================================================
import 'providers/auth_provider.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart'; // Importamos tu vista de registro
import 'views/splash/splash_view.dart';
import 'views/main_layout.dart'; // Importamos tu MainLayout que contiene el Dashboard y otras vistas
// import 'core/routes/app_routes.dart'; // Descomenta esto cuando lo necesites

void main() async {
  // 1. Se asegura de que los widgets de Flutter estén listos.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa los datos de formato de fecha para 'español de España'.
  await initializeDateFormatting('es_ES', null);

  // 3. Inicia la aplicación.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provee el AuthProvider a todos los widgets hijos.
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ery App',
        theme: ThemeData(
          // Define un tema oscuro y moderno para la aplicación.
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF6366F1),
          scaffoldBackgroundColor: const Color(0xFF0E0F1A),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6366F1),
            secondary: Color(0xFF818CF8),
            background: Color(0xFF0E0F1A),
            surface: Color(0xFF1B1D2A),
          ),
          useMaterial3: true,
        ),
        // home decide qué pantalla mostrar al inicio usando nuestro AuthWrapper.
        home: const AuthWrapper(),
        // Define las rutas nombradas para la navegación.
        // Ahora el AuthWrapper maneja la ruta inicial, pero estas sirven para navegación interna.
        routes: {
          // Asegúrate de que estas rutas coincidan con las que usas en tu app
          '/login': (context) => const LoginView(),
          '/register': (context) => const RegisterView(),
          '/dashboard':
              (context) =>
                  const MainLayout(), // MainLayout es tu vista principal post-login
        },
      ),
    );
  }
}

/// AuthWrapper actúa como un "guardia" que dirige al usuario
/// a la pantalla correcta según su estado de autenticación.
/// ¡ESTA ES LA LÓGICA MÁS IMPORTANTE!
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios en el AuthProvider.
    final authProvider = Provider.of<AuthProvider>(context);

    // Si el provider se está inicializando (comprobando el token guardado),
    // muestra tu pantalla de carga.
    if (authProvider.isInitializing) {
      return const SplashView();
    }

    // Si el usuario está autenticado, lo lleva a tu MainLayout,
    // que contiene el Dashboard y la barra lateral.
    if (authProvider.isAuthenticated) {
      return const MainLayout();
    }
    // Si no, lo lleva a tu pantalla de Login.
    else {
      return const LoginView();
    }
  }
}
