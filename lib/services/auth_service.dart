import 'package:dio/dio.dart';
import 'package:ery_flutter_app/core/network/api_client.dart';

class AuthService {
  // 🔐 LOGIN con credenciales (maneja sesión vía cookie)
  static Future<void> login(String email, String password) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/callback/credentials',
        data: {
          "email": email,
          "password": password,
          "callbackUrl": "/dashboard",
          "redirect": false,
        },
      );

      if (response.statusCode == 200 && response.data['url'] != null) {
        print("✅ Login exitoso. URL de retorno: ${response.data['url']}");
        // La cookie de sesión ya fue almacenada automáticamente por dio + cookie_jar
      } else {
        throw Exception('Login fallido: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception("Error en login: ${e.response?.data ?? e.message}");
    }
  }

  // 📝 REGISTRO
  static Future<void> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/register',
        data: {"name": name, "email": email, "password": password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Registro exitoso");
      } else {
        throw Exception('Registro fallido: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception("Error en registro: ${e.response?.data ?? e.message}");
    }
  }

  // 📊 DASHBOARD - Obtener datos del usuario autenticado
  static Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await ApiClient.dio.get('/dashboard');
      return response.data;
    } on DioException catch (e) {
      throw Exception(
        "Error al obtener datos del dashboard: ${e.response?.data ?? e.message}",
      );
    }
  }
}
