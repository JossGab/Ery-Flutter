import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/auth_provider.dart';
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';
import 'views/splash/splash_view.dart';
import 'views/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Ery App',
        theme: ThemeData(
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
        home: const SplashView(), // 👈 Primera pantalla
        routes: {
          '/login': (_) => const LoginView(),
          '/register': (_) => const RegisterView(),
          '/dashboard': (_) => const MainLayout(),
        },
      ),
    );
  }
}
