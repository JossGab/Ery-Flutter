import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Ahora la importación funcionará
import 'package:ery_flutter_app/core/network/api_client.dart';
import 'package:ery_flutter_app/core/routes/app_routes.dart'; // La importación es correcta
import 'package:ery_flutter_app/providers/auth_provider.dart'; // Asegúrate de haber creado este archivo
import 'package:ery_flutter_app/views/auth/login_view.dart';
import 'package:ery_flutter_app/views/dashboard/dashboard_view.dart';
import 'package:ery_flutter_app/views/splash/splash_view.dart';

void main() {
  ApiClient.init(); // Inicializa tu cliente Dio
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Envuelve tu MaterialApp con el ChangeNotifierProvider
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'Ery App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        // Usaremos un "Consumer" o "Wrapper" para decidir qué pantalla mostrar
        home: const AuthWrapper(),
        // Ahora AppRoutes.routes funcionará
        routes: AppRoutes.routes,
      ),
    );
  }
}

// Este Widget actúa como un guardia para la autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isInitializing) {
      return const SplashView(); // O una pantalla de carga
    }

    if (authProvider.isAuthenticated) {
      return const DashboardView();
    } else {
      return const LoginView(); // O tu pantalla de bienvenida/splash con botones
    }
  }
}
