import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// Asegúrate de que estas rutas sean correctas para tu proyecto
import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- ESTADO DE AUTENTICACIÓN ---
  bool _isAuthenticated = false;
  String? _token;
  User? _user;
  bool _isInitializing = true;

  // --- ¡NUEVO! ESTADO DEL DASHBOARD ---
  bool _isDashboardLoading = false;
  Map<String, dynamic>? _dashboardData;
  Map<String, dynamic>? _activityLog;

  // --- GETTERS PÚBLICOS ---
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  User? get user => _user;
  bool get isInitializing => _isInitializing;
  bool get isDashboardLoading => _isDashboardLoading;
  Map<String, dynamic>? get dashboardData => _dashboardData;
  Map<String, dynamic>? get activityLog => _activityLog;

  AuthProvider() {
    tryAutoLogin();
  }

  // --- MÉTODOS DE AUTENTICACIÓN ---

  /// Intenta iniciar sesión automáticamente al abrir la app.
  Future<void> tryAutoLogin() async {
    try {
      final storedToken = await _storage.read(key: 'authToken');
      final storedUser = await _storage.read(key: 'userData');

      if (storedToken != null && storedUser != null) {
        _token = storedToken;
        _user = User.fromJson(json.decode(storedUser));
        _isAuthenticated = true;
      }
    } catch (e) {
      _isAuthenticated = false;
      _token = null;
      _user = null;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Inicia sesión del usuario y guarda el token y los datos.
  Future<void> login(String email, String password) async {
    try {
      final response = await _apiService.login(
        email: email,
        password: password,
      );

      if (response['success'] == true &&
          response.containsKey('token') &&
          response.containsKey('user')) {
        _token = response['token'];
        _user = User.fromJson(response['user']);
        _isAuthenticated = true;

        await _storage.write(key: 'authToken', value: _token);
        await _storage.write(
          key: 'userData',
          value: json.encode(_user!.toJson()),
        );

        notifyListeners();
      } else {
        throw Exception(response['message'] ?? 'Respuesta de login inválida.');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Registra un nuevo usuario.
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

  /// Cierra la sesión del usuario y limpia los datos almacenados.
  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;
    _user = null;
    await _storage.deleteAll();
    notifyListeners();
  }

  // --- ¡NUEVO! MÉTODOS PARA EL DASHBOARD ---

  /// Carga los datos iniciales para la pantalla del dashboard.
  Future<void> fetchDashboardData() async {
    if (_token == null || _isDashboardLoading) return;

    _isDashboardLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();

      // Realizamos las dos llamadas a la API en paralelo para más eficiencia.
      final results = await Future.wait([
        _apiService.getDashboardData(_token!),
        _apiService.getActivityLog(_token!, now.year, now.month),
      ]);

      _dashboardData = results[0];
      _activityLog = results[1];
    } catch (e) {
      debugPrint("Error al obtener los datos del dashboard: $e");
      // Opcional: podrías guardar el mensaje de error para mostrarlo en la UI.
    } finally {
      _isDashboardLoading = false;
      notifyListeners();
    }
  }

  /// Carga el registro de actividad para un mes específico (para la navegación del calendario).
  Future<void> fetchActivityLogForMonth(int year, int month) async {
    if (_token == null) return;

    try {
      _activityLog = await _apiService.getActivityLog(_token!, year, month);
      notifyListeners();
    } catch (e) {
      debugPrint("Error al obtener el log de actividad para $year-$month: $e");
    }
  }
}
