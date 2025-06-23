import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart'; // Para inicializar los datos de localización.

// Importaciones de tus archivos del proyecto.
import 'providers/auth_provider.dart';
import 'views/dashboard/dashboard_view.dart';
import 'views/auth/login_view.dart'; // Cambiado de 'login_view.dart' a 'auth/login_view.dart' para consistencia
import 'views/splash/splash_view.dart';
import 'core/routes/app_routes.dart';

// La función 'main' ahora es 'async' para poder esperar la inicialización.
void main() async {
  // 1. Se asegura de que los widgets de Flutter estén listos.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa los datos de formato de fecha para 'español de España'.
  //    Esto SOLUCIONA el error 'LocaleDataException' del calendario.
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
        // 4. QUITA la cinta de "DEBUG".
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
        routes: AppRoutes.routes,
      ),
    );
  }
}

/// AuthWrapper actúa como un "guardia" que dirige al usuario
/// a la pantalla correcta según su estado de autenticación.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha los cambios en el AuthProvider.
    final authProvider = Provider.of<AuthProvider>(context);

    // Si el provider se está inicializando (comprobando el token guardado),
    // muestra una pantalla de carga.
    if (authProvider.isInitializing) {
      return const SplashView();
    }

    // Si el usuario está autenticado, lo lleva al Dashboard.
    if (authProvider.isAuthenticated) {
      return const DashboardView();
    }
    // Si no, lo lleva a la pantalla de Login.
    else {
      return const LoginView();
    }
  }
}
