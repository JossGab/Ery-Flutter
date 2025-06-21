import 'package:flutter/material.dart';
import 'package:ery_flutter_app/views/auth/login_view.dart';
import 'package:ery_flutter_app/views/auth/register_view.dart';
import 'package:ery_flutter_app/views/dashboard/dashboard_view.dart';
import 'package:ery_flutter_app/views/splash/splash_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ery Flutter App',
      theme: ThemeData.dark(useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashView(),
        '/login': (_) => const LoginView(),
        '/register': (_) => const RegisterView(),
        '/dashboard': (_) => const DashboardView(),
      },
    );
  }
}
