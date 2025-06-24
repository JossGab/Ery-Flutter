/*
================================================================================
 ARCHIVO: lib/services/api_service.dart
 INSTRUCCIONES: Reemplaza el contenido de este archivo.
 Esta versión está corregida y no tiene métodos duplicados.
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
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Error al iniciar sesión');
    }
  }

  /// Registra un nuevo usuario.
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$_baseUrl/auth/register');
    debugPrint('Registrando en: $url');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': name.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );
    debugPrint('Respuesta de registro: ${response.statusCode}');
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Error durante el registro.');
    }
  }

  /// Obtiene los datos del dashboard del usuario autenticado.
  Future<Map<String, dynamic>> getDashboardData() async {
    final token = await getToken();
    if (token == null) throw Exception('No autenticado.');

    final url = Uri.parse('$_baseUrl/dashboard');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      await deleteToken();
      throw Exception('Sesión expirada. Inicia sesión de nuevo.');
    }
  }

  /// Obtiene la lista de hábitos del usuario autenticado.
  Future<List<dynamic>> getHabits() async {
    final token = await getToken();
    if (token == null) throw Exception('No autenticado.');

    final url = Uri.parse('$_baseUrl/habits');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['habits'];
    } else {
      throw Exception('Error al obtener los hábitos.');
    }
  }

  /// Crea un nuevo hábito para el usuario autenticado.
  Future<Map<String, dynamic>> createHabit(
    Map<String, dynamic> habitData,
  ) async {
    final token = await getToken();
    if (token == null) throw Exception('No autenticado.');

    final url = Uri.parse('$_baseUrl/habits');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(habitData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body)['habit'];
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Error al crear el hábito.');
    }
  }

  /// Registra el progreso de un hábito para el usuario autenticado.
  Future<void> logHabitProgress(Map<String, dynamic> logData) async {
    final token = await getToken();
    if (token == null) throw Exception('No autenticado.');

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
      final errorData = json.decode(response.body);
      throw Exception(
        errorData['message'] ?? 'Error al registrar el progreso.',
      );
    }
  }
}
