// lib/services/auth_service.dart (Versión Corregida y Simplificada)

import 'package:ery_flutter_app/services/api_service.dart';
import 'package:ery_flutter_app/models/user_model.dart';

class AuthService {
  // Obtenemos la instancia única (singleton) de nuestro ApiService funcional.
  // Todas las llamadas a la red pasarán por aquí.
  final ApiService _apiService = ApiService();

  /// El método login ahora actúa como un puente directo al ApiService.
  /// Llama a la API, y si tiene éxito, convierte la respuesta en un objeto User.
  Future<User> login(String email, String password) async {
    try {
      // 1. Llama al método login de ApiService, que maneja el token.
      final userData = await _apiService.login(email, password);

      // 2. Convierte el mapa JSON de la respuesta en nuestro modelo User.
      return User.fromJson(userData);
    } catch (e) {
      // 3. Si hay un error (ej. credenciales incorrectas), lo re-lanza
      //    para que el AuthProvider y el UI puedan mostrar el mensaje.
      rethrow;
    }
  }

  /// Lo mismo para el registro. Pasa la llamada directamente al ApiService.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      await _apiService.register(name: name, email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  /// El logout simplemente llama al método estático para borrar el token en ApiService.
  Future<void> logout() async {
    // No necesita llamar a la API, solo borra el token local.
    await ApiService.deleteToken();
  }
}
