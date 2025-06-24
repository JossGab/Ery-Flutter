import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// Asegúrate de que las rutas a tus archivos sean correctas
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/habit_model.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _user;
  bool _isInitializing = true;
  bool _isLoading = false;
  List<Habit> _habits = [];

  // --- GETTERS PÚBLICOS ---
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isInitializing => _isInitializing;
  bool get isLoading => _isLoading;
  List<Habit> get habits => _habits;
  int get activeHabitsCount => _habits.length;

  int get bestStreak {
    if (_habits.isEmpty) return 0;
    return _habits.fold(
      0,
      (max, h) => h.rachaActual > max ? h.rachaActual : max,
    );
  }

  // --- CONSTRUCTOR ---
  AuthProvider() {
    tryAutoLogin();
  }

  // --- LÓGICA DE AUTENTICACIÓN ---

  Future<void> tryAutoLogin() async {
    final token = await ApiService.getToken();
    if (token == null || JwtDecoder.isExpired(token)) {
      await ApiService.deleteToken();
      _isInitializing = false;
      notifyListeners();
      return;
    }
    try {
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      _user = User.fromJson(decodedToken);
      await fetchDashboardData(); // Carga los datos después de un auto-login exitoso
    } catch (e) {
      debugPrint("Fallo en tryAutoLogin: $e");
      await logout();
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      final userData = await _apiService.login(email, password);
      _user = User.fromJson(userData);
      // La navegación la maneja el AuthWrapper, ahora solo notificamos
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      await _apiService.register(name: name, email: email, password: password);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _user = null;
    _habits = [];
    await ApiService.deleteToken();
    notifyListeners();
  }

  // ===================================================================
  // MÉTODOS AÑADIDOS PARA MANEJAR HÁBITOS
  // ===================================================================

  /// Llama al ApiService para crear un nuevo hábito y luego refresca la lista.
  Future<void> createHabit(Map<String, dynamic> habitData) async {
    _setLoading(true);
    try {
      await _apiService.createHabit(habitData);
      // Después de crear, volvemos a pedir los datos del dashboard para tener la lista actualizada.
      await fetchDashboardData();
    } catch (e) {
      rethrow; // Propagamos el error para que el UI lo muestre.
    } finally {
      _setLoading(false);
    }
  }

  /// Llama al ApiService para registrar el progreso y luego refresca los datos de los hábitos.
  Future<void> logHabitProgress(Map<String, dynamic> logData) async {
    // No activamos el loading global para que la UI se sienta más fluida.
    // El botón individual puede mostrar su propio estado de carga si es necesario.
    try {
      await _apiService.logHabitProgress(logData);
      // Hacemos una recarga silenciosa de los datos para actualizar las rachas.
      await fetchDashboardData();
    } catch (e) {
      rethrow; // Propagamos el error para que el UI lo muestre.
    }
  }
  // ===================================================================

  /// Obtiene los datos del dashboard (hábitos y estadísticas) y los guarda en el provider.
  Future<void> fetchDashboardData() async {
    try {
      final data = await _apiService.getDashboardData();
      final habitsData = data['habits_con_estadisticas'] as List;
      _habits = habitsData.map((json) => Habit.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Fallo al obtener datos del dashboard: $e");
      if (e.toString().contains('Sesión expirada')) {
        await logout();
      }
      rethrow;
    } finally {
      // Notificamos al UI que los datos (o la falta de ellos) han sido actualizados.
      notifyListeners();
    }
  }

  /// Helper para gestionar el estado de carga y notificar a los listeners.
  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }
}
