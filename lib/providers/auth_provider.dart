import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// Asegúrate de que las rutas a tus archivos sean correctas
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/habit_model.dart';

// --- AÑADIDO ---
// Imports necesarios para el sistema de logros
import '../services/achievement_service.dart';
import '../models/achievement_model.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _user;
  bool _isInitializing = true;
  bool _isLoading = false;
  List<Habit> _habits = [];

  // --- AÑADIDO ---
  // Propiedades para gestionar los logros
  final AchievementService _achievementService = AchievementService();
  List<Achievement> _newlyUnlockedAchievements = [];

  // --- GETTERS PÚBLICOS ---
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isInitializing => _isInitializing;
  bool get isLoading => _isLoading;
  List<Habit> get habits => _habits;
  int get activeHabitsCount => _habits.length;

  // --- AÑADIDO ---
  // Getter para que la UI pueda acceder a los logros recién desbloqueados
  List<Achievement> get newlyUnlockedAchievements => _newlyUnlockedAchievements;

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
      // Después de un login exitoso, cargamos los datos del dashboard y logros
      await fetchDashboardData();
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
    _newlyUnlockedAchievements = []; // Limpiamos logros al cerrar sesión
    await ApiService.deleteToken();
    notifyListeners();
  }

  // ===================================================================
  // MÉTODOS PARA MANEJAR HÁBITOS
  // ===================================================================

  Future<void> createHabit(Map<String, dynamic> habitData) async {
    _setLoading(true);
    try {
      await _apiService.createHabit(habitData);
      await fetchDashboardData();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logHabitProgress(Map<String, dynamic> logData) async {
    try {
      await _apiService.logHabitProgress(logData);
      await fetchDashboardData();
    } catch (e) {
      rethrow;
    }
  }

  // ===================================================================

  /// Obtiene los datos del dashboard y verifica los logros.
  Future<void> fetchDashboardData() async {
    try {
      final data = await _apiService.getDashboardData();
      final habitsData = data['habits_con_estadisticas'] as List;
      _habits = habitsData.map((json) => Habit.fromJson(json)).toList();

      // --- AÑADIDO ---
      // Verificamos si se ha desbloqueado algún logro con los datos actualizados.
      _newlyUnlockedAchievements = await _achievementService
          .checkAndUnlockAchievements(_habits);
    } catch (e) {
      debugPrint("Fallo al obtener datos del dashboard: $e");
      if (e.toString().contains('Sesión expirada')) {
        await logout();
      }
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  // --- AÑADIDO ---
  /// Método para que la UI informe al provider que ya ha mostrado las notificaciones de nuevos logros.
  void clearNewAchievements() {
    _newlyUnlockedAchievements = [];
    // No es necesario notificar a los listeners aquí, ya que esto es una limpieza silenciosa.
  }

  /// Helper para gestionar el estado de carga y notificar a los listeners.
  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }
}
