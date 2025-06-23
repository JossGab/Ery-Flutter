// lib/providers/auth_provider.dart (La versión correcta para Tokens JWT)
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ery_flutter_app/services/api_service.dart'; // ¡Asegúrate que apunte a tu nuevo ApiService!
import '../models/user_model.dart'; // El modelo de usuario que ya creamos

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  String? _token;
  User? _user;
  bool _isInitializing = true; // Para la pantalla de carga inicial

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  User? get user => _user;
  bool get isInitializing => _isInitializing;

  AuthProvider() {
    tryAutoLogin();
  }

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
      // Manejo de errores
      _isAuthenticated = false;
      _token = null;
      _user = null;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

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
          value: json.encode(
            _user!.toJson(),
          ), // ¡Necesitamos un método toJson en el modelo!
        );

        notifyListeners();
      } else {
        throw Exception(response['message'] ?? 'Respuesta de login inválida.');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _token = null;
    _user = null;
    await _storage.deleteAll();
    notifyListeners();
  }
}
