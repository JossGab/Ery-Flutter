import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Asegúrate de que las rutas a tus archivos sean correctas
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../models/habit_model.dart';

// Imports necesarios para el sistema de logros
import '../services/achievement_service.dart';
import '../models/achievement_model.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _user;
  bool _isInitializing = true;
  bool _isLoading = false;
  List<Habit> _habits = [];

  // --- AÑADIDO: Estado para el perfil del usuario ---
  Map<String, dynamic>? _userProfile;

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
  List<Achievement> get newlyUnlockedAchievements => _newlyUnlockedAchievements;

  // --- AÑADIDO: Getter para el perfil ---
  Map<String, dynamic>? get userProfile => _userProfile;

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

  // --- LÓGICA DE AUTENTICACIÓN Y PERFIL---

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
      await fetchProfile(); // <-- AÑADIDO: Cargar perfil al iniciar
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
      await fetchDashboardData();
      await fetchProfile(); // <-- AÑADIDO: Cargar perfil al iniciar sesión
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _setLoading(false);
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        throw Exception('No se pudo obtener el ID Token de Google.');
      }
      final userData = await _apiService.loginWithGoogle(idToken);
      _user = User.fromJson(userData);
      await fetchDashboardData();
      await fetchProfile(); // <-- AÑADIDO: Cargar perfil tras login con Google
    } catch (e) {
      debugPrint("Error en signInWithGoogle: $e");
      rethrow;
    } finally {
      _setLoading(false);
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

  // --- AÑADIDO: Métodos para gestionar el perfil ---
  Future<void> fetchProfile() async {
    if (!isAuthenticated) return;
    try {
      _userProfile = await _apiService.getProfile();
      notifyListeners();
    } catch (e) {
      debugPrint("Error al cargar el perfil: $e");
    }
  }

  Future<bool> updateUserProfile({
    String? newName,
    String? newPassword,
    String? currentPassword,
    String? confirmNewPassword,
  }) async {
    if (!isAuthenticated) return false;
    _setLoading(true);
    try {
      await _apiService.updateProfile(
        nombre: newName,
        nuevaContrasena: newPassword,
        contrasenaActual: currentPassword,
        confirmarNuevaContrasena: confirmNewPassword,
      );
      // Vuelve a cargar el perfil para obtener los datos actualizados
      await fetchProfile();
      return true;
    } catch (e) {
      debugPrint("Error al actualizar el perfil: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await GoogleSignIn().signOut();
    _user = null;
    _userProfile = null; // <-- AÑADIDO: Limpiar perfil al cerrar sesión
    _habits = [];
    _newlyUnlockedAchievements = [];
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

  /// Actualiza un hábito existente.
  Future<void> updateHabit(int habitId, Map<String, dynamic> habitData) async {
    _setLoading(true);
    try {
      await _apiService.updateHabit(habitId, habitData);
      // Después de actualizar, recargamos los datos para reflejar los cambios
      await fetchDashboardData();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Elimina un hábito.
  Future<void> deleteHabit(int habitId) async {
    _setLoading(true);
    try {
      await _apiService.deleteHabit(habitId);
      // Quita el hábito de la lista local para una actualización instantánea en la UI
      _habits.removeWhere((habit) => habit.id == habitId);
    } catch (e) {
      // Si falla, recarga los datos para asegurar la consistencia
      await fetchDashboardData();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ===================================================================

  /// Obtiene los datos del dashboard.
  Future<void> fetchDashboardData() async {
    try {
      final data = await _apiService.getDashboardData();
      final habitsData = data['habits_con_estadisticas'] as List;
      _habits = habitsData.map((json) => Habit.fromJson(json)).toList();

      // ===== CORRECCIÓN =====
      // Se elimina la siguiente línea porque el método ya no existe en AchievementService.
      // La lógica de desbloqueo ahora la hace la API.
      // _newlyUnlockedAchievements = await _achievementService.checkAndUnlockAchievements(_habits);
      // ======================
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

  /// Método para que la UI informe al provider que ya ha mostrado las notificaciones de nuevos logros.
  void clearNewAchievements() {
    _newlyUnlockedAchievements = [];
  }

  /// Helper para gestionar el estado de carga y notificar a los listeners.
  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    notifyListeners();
  }
}
