import 'package:flutter/material.dart';
import 'package:ery_flutter_app/views/auth/login_view.dart';
import 'package:ery_flutter_app/views/auth/register_view.dart';
import 'package:ery_flutter_app/views/dashboard/dashboard_view.dart';
import 'package:ery_flutter_app/views/splash/splash_view.dart';

class AppRoutes {
  // --- AÑADIMOS CONSTANTES ESTÁTICAS PARA LOS NOMBRES DE LAS RUTAS ---
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';

  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashView(),
    login: (context) => const LoginView(),
    register: (context) => const RegisterView(),
    dashboard: (context) => const DashboardView(),
  };
}
