// lib/services/auth_service.dart (Versión Mejorada)
import 'package:dio/dio.dart';
import 'package:ery_flutter_app/core/network/api_client.dart';
import 'package:ery_flutter_app/models/user_model.dart'; // ¡Importar el modelo!

class AuthService {
  final Dio _dio = ApiClient.dio;

  // El método de login no cambia mucho, pero ahora el Provider lo usará.
  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/callback/credentials',
        data: {"email": email, "password": password, "redirect": false},
      );
      if (response.statusCode != 200 || response.data['url'] == null) {
        throw Exception("Credenciales inválidas.");
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ?? "Error en el login.";
      throw Exception(errorMessage);
    }
  }

  // ¡NUEVO MÉTODO! Para obtener la sesión del usuario.
  Future<User?> getSession() async {
    try {
      final response = await _dio.get('/auth/session');
      if (response.statusCode == 200 && response.data['user'] != null) {
        // Devuelve un objeto User creado desde el JSON
        return User.fromJson(response.data['user']);
      }
      return null;
    } on DioException {
      // Si hay un error (ej. 401 no autorizado), significa que no hay sesión.
      return null;
    }
  }

  // El método de registro puede permanecer igual.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // ... tu código de registro actual ...
  }

  // ¡NUEVO MÉTODO! Para cerrar sesión.
  Future<void> logout() async {
    try {
      // Llama al endpoint de signout y no nos preocupamos por la respuesta.
      await _dio.post('/auth/signout', data: {});
    } catch (e) {
      // Ignoramos errores, ya que solo queremos asegurarnos de que el cliente olvide la sesión.
      print("Error durante el logout, pero se procederá en el cliente: $e");
    }
  }
}
