/*
================================================================================
 ARCHIVO: lib/services/api_service.dart
 INSTRUCCIONES: Reemplaza el contenido de este archivo.
 Esta versión añade los métodos para Perfil, Logros y Amigos, además
 del método para autenticación con Google.
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

  // ===================================================================
  // MÉTODO NUEVO: Autenticación con Google
  // ===================================================================
  /// Inicia sesión o registra un usuario usando un ID Token de Google.
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    // Asumimos que el endpoint en tu backend será /api/auth/google
    // Tu compañero de backend debe crear este endpoint.
    final url = Uri.parse('$_baseUrl/auth/google');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'idToken': idToken}),
    );

    debugPrint('Respuesta de login con Google: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final token = data['token'];
      final user = data['user'];
      if (token != null && user != null) {
        await _saveToken(token); // Guardamos el token de NUESTRO backend
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

  // --- MÉTODO GENÉRICO PARA PETICIONES AUTENTICADAS ---
  // Este método simplifica todas las llamadas futuras.
  Future<T> _makeAuthenticatedRequest<T>(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No autenticado.');
    }

    final url = Uri.parse('$_baseUrl$path');
    http.Response response;

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    debugPrint('Petición: $method $url');
    if (body != null) {
      debugPrint('Cuerpo: ${json.encode(body)}');
    }

    try {
      switch (method.toUpperCase()) {
        case 'POST':
          response = await http.post(
            url,
            headers: headers,
            body: json.encode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: headers,
            body: json.encode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers);
          break;
        default: // GET
          response = await http.get(url, headers: headers);
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          // Para respuestas como 204 No Content
          return null as T;
        }
        return json.decode(utf8.decode(response.bodyBytes)) as T;
      } else {
        throw _handleErrorResponse(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- MÉTODOS EXISTENTES (Refactorizados para usar el método genérico) ---

  Future<Map<String, dynamic>> getDashboardData() {
    return _makeAuthenticatedRequest<Map<String, dynamic>>('/dashboard');
  }

  // ===================================================================
  // MÉTODOS PARA MANEJAR HÁBITOS (Existentes y Nuevos)
  // ===================================================================

  /// Obtiene la lista de hábitos del usuario.
  Future<List<dynamic>> getHabits() async {
    final response = await _makeAuthenticatedRequest<Map<String, dynamic>>(
      '/habits',
    );
    return response['habits'] as List<dynamic>;
  }

  /// Crea un nuevo hábito para el usuario.
  Future<Map<String, dynamic>> createHabit(
    Map<String, dynamic> habitData,
  ) async {
    final response = await _makeAuthenticatedRequest<Map<String, dynamic>>(
      '/habits',
      method: 'POST',
      body: habitData,
    );
    return response['habit'] as Map<String, dynamic>;
  }

  /// Registra el progreso de un hábito para una fecha específica.
  Future<void> logHabitProgress(Map<String, dynamic> logData) {
    return _makeAuthenticatedRequest<void>(
      '/habits/log',
      method: 'POST',
      body: logData,
    );
  }

  // --- AÑADIDOS: Métodos para editar y eliminar hábitos ---

  /// Actualiza los detalles de un hábito existente.
  /// Llama a: PUT /api/habits/{habitoId}
  Future<Map<String, dynamic>> updateHabit(
    int habitId,
    Map<String, dynamic> habitData,
  ) {
    return _makeAuthenticatedRequest<Map<String, dynamic>>(
      '/habits/$habitId',
      method: 'PUT',
      body: habitData,
    );
  }

  /// Elimina un hábito de forma permanente.
  /// Llama a: DELETE /api/habits/{habitoId}
  Future<void> deleteHabit(int habitId) {
    return _makeAuthenticatedRequest<void>(
      '/habits/$habitId',
      method: 'DELETE',
    );
  }

  // ===================================================================
  // AÑADIDOS: activity, calendar
  // ===================================================================
  Future<Map<String, dynamic>> getActivityLog(int year, int month) {
    return _makeAuthenticatedRequest<Map<String, dynamic>>(
      '/activity-log?year=$year&month=$month',
    );
  }

  // ===================================================================
  // AÑADIDOS: Perfil, Logros, Amigos
  // ===================================================================

  // -- PERFIL --
  Future<Map<String, dynamic>> getProfile() {
    return _makeAuthenticatedRequest<Map<String, dynamic>>('/profile');
  }

  Future<Map<String, dynamic>> updateProfile({
    String? nombre,
    String? contrasenaActual,
    String? nuevaContrasena,
    String? confirmarNuevaContrasena,
  }) {
    final body = <String, dynamic>{};
    if (nombre != null) body['nombre'] = nombre;
    if (contrasenaActual != null) body['contraseñaActual'] = contrasenaActual;
    if (nuevaContrasena != null) body['nuevaContraseña'] = nuevaContrasena;
    if (confirmarNuevaContrasena != null)
      body['confirmarNuevaContraseña'] = confirmarNuevaContrasena;

    return _makeAuthenticatedRequest<Map<String, dynamic>>(
      '/profile',
      method: 'PUT',
      body: body,
    );
  }

  // ===================================================================
  // AÑADIDOS: Métodos para la gestión de Amigos
  // ===================================================================

  /// Busca usuarios por nombre o email.
  /// Llama a: GET /api/users/search?q={query}
  Future<List<dynamic>> searchUsers(String query) async {
    if (query.length < 2) return [];
    final response = await _makeAuthenticatedRequest<Map<String, dynamic>>(
      '/users/search?q=$query',
    );
    return response['users'] as List<dynamic>;
  }

  /// Envía una solicitud de amistad a un usuario.
  /// Llama a: POST /api/friends/invitations
  Future<void> sendFriendInvitation(int userId) {
    return _makeAuthenticatedRequest<void>(
      '/friends/invitations',
      method: 'POST',
      body: {'solicitado_id': userId},
    );
  }

  /// Obtiene las invitaciones de amistad enviadas y recibidas.
  /// Llama a: GET /api/friends/invitations
  Future<Map<String, dynamic>> getFriendInvitations() {
    return _makeAuthenticatedRequest<Map<String, dynamic>>(
      '/friends/invitations',
    );
  }

  /// Responde a una invitación de amistad (aceptar o rechazar).
  /// Llama a: PUT /api/friends/invitations/{invitationId}
  Future<void> respondToInvitation(int invitationId, String action) {
    // 'action' debe ser 'accept' o 'reject'
    return _makeAuthenticatedRequest<void>(
      '/friends/invitations/$invitationId',
      method: 'PUT',
      body: {'action': action},
    );
  }

  /// Obtiene la lista de amigos del usuario.
  /// Llama a: GET /api/friends
  Future<List<dynamic>> getFriends() async {
    final response = await _makeAuthenticatedRequest<Map<String, dynamic>>(
      '/friends',
    );
    return response['friends'] as List<dynamic>;
  }

  /// Obtiene las estadísticas de un amigo específico.
  /// Llama a: GET /api/users/{userId}/stats
  Future<Map<String, dynamic>> getFriendStats(int friendId) {
    return _makeAuthenticatedRequest<Map<String, dynamic>>(
      '/users/$friendId/stats',
    );
  }

  /// Elimina a un amigo.
  /// Llama a: DELETE /api/friends/{friendId}
  Future<void> deleteFriend(int friendId) {
    return _makeAuthenticatedRequest<void>(
      '/friends/$friendId',
      method: 'DELETE',
    );
  }

  // ===================================================================
  // AÑADIDOS: Métodos para la gestión de Rutinas
  // ===================================================================

  /// Obtiene todas las rutinas del usuario.
  Future<List<dynamic>> getRoutines() async {
    final response = await _makeAuthenticatedRequest<Map<String, dynamic>>(
      '/routines',
    );
    return response['routines'] as List<dynamic>;
  }

  /// Crea una nueva rutina.
  Future<Map<String, dynamic>> createRoutine(
    String nombre,
    String? descripcion,
  ) async {
    final body = {'nombre': nombre};
    if (descripcion != null) {
      body['descripcion'] = descripcion;
    }
    final response = await _makeAuthenticatedRequest<Map<String, dynamic>>(
      '/routines',
      method: 'POST',
      body: body,
    );
    return response['routine'] as Map<String, dynamic>;
  }

  /// Obtiene los detalles de una rutina específica, incluyendo sus hábitos.
  Future<Map<String, dynamic>> getRoutineDetails(int routineId) {
    return _makeAuthenticatedRequest<Map<String, dynamic>>(
      '/routines/$routineId',
    );
  }

  /// Asocia un hábito existente a una rutina.
  Future<void> addHabitToRoutine(int routineId, int habitId) {
    return _makeAuthenticatedRequest<void>(
      '/routines/$routineId/habits',
      method: 'POST',
      body: {'habitId': habitId},
    );
  }

  /// Elimina un hábito de una rutina.
  /// ¡Importante! La API espera el habitId en el cuerpo de una petición DELETE.
  Future<void> removeHabitFromRoutine(int routineId, int habitId) async {
    final token = await getToken();
    if (token == null) throw Exception('No autenticado.');

    final url = Uri.parse('$_baseUrl/routines/$routineId/habits');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = json.encode({'habitId': habitId});

    // La librería http.delete no soporta un body directamente, se usa http.Request.
    final request =
        http.Request('DELETE', url)
          ..headers.addAll(headers)
          ..body = body;

    final response = await http.Client()
        .send(request)
        .then(http.Response.fromStream);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _handleErrorResponse(response);
    }
  }

  /// Elimina una rutina específica.
  Future<void> deleteRoutine(int routineId) {
    return _makeAuthenticatedRequest<void>(
      '/routines/$routineId',
      method: 'DELETE',
    );
  }

  // ===================================================================
  // AÑADIDO: Método para Logros
  // ===================================================================

  /// Obtiene la lista completa de logros y su estado de desbloqueo.
  Future<List<dynamic>> getAchievements() async {
    // La API devuelve un objeto {"achievements": [...]}, extraemos la lista.
    final response = await _makeAuthenticatedRequest<Map<String, dynamic>>(
      '/achievements',
    );
    return response['achievements'] as List<dynamic>;
  }

  // ===================================================================
  // AÑADIDO: Método para Rankings
  // ===================================================================

  /// Obtiene la clasificación de usuarios.
  /// scope puede ser 'global' o 'country'.
  Future<List<dynamic>> getRankings({String scope = 'global'}) async {
    final response = await _makeAuthenticatedRequest<Map<String, dynamic>>(
      '/rankings?scope=$scope',
    );
    // La API devuelve un objeto {"rankings": [...]}, extraemos la lista.
    return response['rankings'] as List<dynamic>;
  }

  // ===================================================================
  // AÑADIDOS: Métodos para la gestión de Competiciones
  // ===================================================================

  /// Obtiene las competencias del usuario (creadas y en las que participa).
  /// Llama a: GET /api/competitions/my
  Future<Map<String, dynamic>> getMyCompetitions() {
    // Pedimos que incluya estadísticas básicas para mostrar en la lista
    return _makeAuthenticatedRequest<Map<String, dynamic>>(
      '/competitions/my?include_stats=true',
    );
  }

  /// Crea una nueva competición.
  /// Llama a: POST /api/competitions
  Future<Map<String, dynamic>> createCompetition(
    Map<String, dynamic> competitionData,
  ) {
    return _makeAuthenticatedRequest<Map<String, dynamic>>(
      '/competitions',
      method: 'POST',
      body: competitionData,
    );
  }

  /// Obtiene los detalles y la clasificación de una competencia.
  /// Llama a: GET /api/competitions/{id}/leaderboard
  Future<Map<String, dynamic>> getCompetitionLeaderboard(int competitionId) {
    return _makeAuthenticatedRequest<Map<String, dynamic>>(
      '/competitions/$competitionId/leaderboard',
    );
  }

  /// Permite que un usuario se una a una competencia.
  /// Llama a: POST /api/competitions/{id}/join
  Future<Map<String, dynamic>> joinCompetition(int competitionId) {
    return _makeAuthenticatedRequest<Map<String, dynamic>>(
      '/competitions/$competitionId/join',
      method: 'POST',
    );
  }
}
