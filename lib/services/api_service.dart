/*
================================================================================
 ARCHIVO: lib/services/api_service.dart
 INSTRUCCIONES: Reemplaza el contenido de este archivo.
 Esta versión añade un log para verificar el token antes de cada envío.
================================================================================
*/
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String _baseUrl = "https://ery-app-turso.vercel.app/api";
  static const _storage = FlutterSecureStorage();

  static Future<void> _saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  // --- FUNCIÓN PRIVADA PARA MANEJAR ERRORES DE FORMA CONSISTENTE ---
  Exception _handleErrorResponse(http.Response response) {
    debugPrint(
      'API Error - Status: ${response.statusCode}, Body: ${response.body}',
    );
    // Si el error es de autenticación, borramos el token y cerramos sesión.
    if (response.statusCode == 401 || response.statusCode == 403) {
      deleteToken();
      return Exception(
        'Tu sesión ha expirado. Por favor, inicia sesión de nuevo.',
      );
    }

    // Para cualquier otro error, mostramos el mensaje del servidor.
    try {
      final errorData = json.decode(response.body);
      return Exception(errorData['message'] ?? 'Ocurrió un error inesperado.');
    } catch (_) {
      // Si el cuerpo de la respuesta no es un JSON válido
      return Exception('Ocurrió un error inesperado en el servidor.');
    }
  }

  /// Inicia sesión y devuelve los datos del usuario.
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/token');
    debugPrint('Iniciando sesión en: $url');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email.trim(), 'password': password.trim()}),
    );
    debugPrint('Respuesta de login: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];
      final user = data['user'];
      if (token != null && user != null) {
        await _saveToken(token);
        return user;
      } else {
        throw Exception('Respuesta de API inválida.');
      }
    } else {
      throw _handleErrorResponse(response);
    }
  }

  /// Registra un nuevo usuario.
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': name.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw _handleErrorResponse(response);
    }
  }

  // --- MÉTODOS QUE REQUIEREN AUTENTICACIÓN ---

  Future<T> _makeAuthenticatedRequest<T>(
    Future<http.Response> Function(String token) request,
  ) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No autenticado.');
    }

    // **AÑADIDO**: Log para verificar el token antes de usarlo.
    debugPrint('Enviando petición con token: $token');

    final response = await request(token);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Asumimos que T es el tipo de dato decodificado del JSON
      return json.decode(response.body) as T;
    } else {
      throw _handleErrorResponse(response);
    }
  }

  /// Obtiene los datos del dashboard del usuario autenticado.
  Future<Map<String, dynamic>> getDashboardData() async {
    return await _makeAuthenticatedRequest<Map<String, dynamic>>((token) {
      final url = Uri.parse('$_baseUrl/dashboard');
      return http.get(url, headers: {'Authorization': 'Bearer $token'});
    });
  }

  /// Obtiene la lista de hábitos del usuario autenticado.
  Future<List<dynamic>> getHabits() async {
    final Map<String, dynamic> data =
        await _makeAuthenticatedRequest<Map<String, dynamic>>((token) {
          final url = Uri.parse('$_baseUrl/habits');
          return http.get(url, headers: {'Authorization': 'Bearer $token'});
        });
    return data['habits'];
  }

  /// Crea un nuevo hábito para el usuario autenticado.
  Future<Map<String, dynamic>> createHabit(
    Map<String, dynamic> habitData,
  ) async {
    final Map<String, dynamic> data =
        await _makeAuthenticatedRequest<Map<String, dynamic>>((token) {
          final url = Uri.parse('$_baseUrl/habits');
          return http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(habitData),
          );
        });
    return data['habit'];
  }

  /// Registra el progreso de un hábito para el usuario autenticado.
  Future<void> logHabitProgress(Map<String, dynamic> logData) async {
    final token = await getToken();
    if (token == null) throw Exception('No autenticado.');

    debugPrint('Enviando petición de progreso con token: $token');

    final url = Uri.parse('$_baseUrl/habits/log');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(logData),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw _handleErrorResponse(response);
    }
  }

  // ===================================================================
  // MÉTODO CORREGIDO: Apunta al endpoint correcto en el backend.
  // ===================================================================
  /// Obtiene el registro de actividad de un mes y año específicos.
  Future<Map<String, dynamic>> getActivityLog(int year, int month) async {
    return await _makeAuthenticatedRequest<Map<String, dynamic>>((token) {
      final url = Uri.parse('$_baseUrl/activity-log?year=$year&month=$month');

      debugPrint('Fetching activity log from: $url');

      return http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json', // Es buena práctica incluirlo
        },
      );
    });
  }
}
