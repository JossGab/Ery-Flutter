import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiService {
  final String _baseUrl = "https://ery-app-turso.vercel.app/api";

  // --- MÉTODOS DE AUTENTICACIÓN ---

  /// Inicia sesión de un usuario y devuelve los datos incluyendo el token.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Llama al método POST genérico para el endpoint de login.
    return _postRequest('/auth/token', {'email': email, 'password': password});
  }

  /// Registra un nuevo usuario.
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Llama al método POST genérico para el endpoint de registro.
    return _postRequest('/auth/register', {
      'nombre': name,
      'email': email,
      'password': password,
    });
  }

  // --- MÉTODOS PARA EL DASHBOARD ---

  /// Obtiene los datos principales del dashboard (estadísticas de hábitos).
  /// Requiere el token JWT para la autenticación.
  Future<Map<String, dynamic>> getDashboardData(String token) async {
    return await _getRequest('/dashboard', token);
  }

  /// Obtiene el registro de actividad para un mes y año específicos.
  /// Requiere el token JWT para la autenticación.
  Future<Map<String, dynamic>> getActivityLog(
    String token,
    int year,
    int month,
  ) async {
    // Construye el endpoint con los parámetros de consulta.
    final endpoint = '/activity-log?year=$year&month=$month';
    return await _getRequest(endpoint, token);
  }

  // --- MÉTODOS PRIVADOS DE MANEJO DE PETICIONES ---

  /// Método genérico para realizar peticiones POST.
  Future<Map<String, dynamic>> _postRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    debugPrint('POST a: $url con body: $body');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      debugPrint('Error de red: No se pudo conectar al host.');
      throw Exception('Error de red: Revisa tu conexión a internet.');
    } on http.ClientException catch (e) {
      debugPrint('Error de cliente HTTP: ${e.message}');
      throw Exception('Error de conexión con el servidor.');
    } catch (e) {
      debugPrint('Error inesperado en POST: ${e.toString()}');
      throw Exception('Ocurrió un error inesperado.');
    }
  }

  /// Método genérico para realizar peticiones GET autenticadas.
  Future<Map<String, dynamic>> _getRequest(
    String endpoint,
    String token,
  ) async {
    final url = Uri.parse('$_baseUrl$endpoint');
    debugPrint('GET a: $url');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Adjuntamos el token JWT en la cabecera para la autorización.
          'Authorization': 'Bearer $token',
        },
      );
      return _handleResponse(response);
    } on SocketException {
      debugPrint('Error de red: No se pudo conectar al host.');
      throw Exception('Error de red: Revisa tu conexión a internet.');
    } catch (e) {
      debugPrint('Error inesperado en GET: ${e.toString()}');
      throw Exception('Ocurrió un error inesperado.');
    }
  }

  /// Centraliza el manejo de las respuestas HTTP.
  Map<String, dynamic> _handleResponse(http.Response response) {
    debugPrint(
      'Respuesta recibida: ${response.statusCode} con body: ${response.body}',
    );

    final responseBody =
        response.body.isNotEmpty ? json.decode(response.body) : {};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      // Si el servidor devuelve un error, extrae el mensaje específico.
      final errorMessage =
          responseBody['message'] ??
          'El servidor devolvió un error sin mensaje.';
      throw Exception(errorMessage);
    }
  }
}
