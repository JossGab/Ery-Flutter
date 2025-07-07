import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/achievement_model.dart';
import '../models/habit_model.dart';

// Hacemos que el servicio notifique a los listeners cuando hay cambios de estado
class AchievementService with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Achievement> _achievements = [];
  bool _isLoading = false;
  String? _error;

  // Getters para que la UI acceda al estado de forma segura
  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga la lista de logros y su estado desde la API.
  Future<void> fetchAchievements() async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Notifica a la UI que estamos cargando

    try {
      final achievementsData = await _apiService.getAchievements();

      // Convertimos los datos JSON en nuestra lista de modelos Achievement
      _achievements =
          achievementsData.map((data) {
            return Achievement(
              id: data['id'].toString(),
              title: data['nombre'],
              description: data['descripcion'],
              // El ícono viene como string, lo mapeamos a un IconData real
              icon: _getIconFromString(data['icono_url']),
              isUnlocked: data['unlocked'] ?? false,
            );
          }).toList();
    } catch (e) {
      _error = e.toString();
      debugPrint("Error al cargar logros: $_error");
    } finally {
      _isLoading = false;
      notifyListeners(); // Notifica a la UI que la carga terminó (con éxito o error)
    }
  }

  // Función de ayuda para convertir el nombre del icono en un objeto IconData.
  // Es importante que los nombres de los iconos coincidan con los que envía la API.
  static IconData _getIconFromString(String? iconName) {
    switch (iconName) {
      case 'star_border':
        return Icons.star_border;
      case 'whatshot':
        return Icons.whatshot;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'playlist_add_check':
        return Icons.playlist_add_check;
      default:
        return Icons
            .emoji_events_outlined; // Un ícono por defecto si no se encuentra
    }
  }

  // Esta función ya no es necesaria, ya que el backend determina los logros.
  // La mantenemos por compatibilidad con el AuthProvider, pero podría eliminarse.
  Future<List<Achievement>> checkAndUnlockAchievements(
    List<Habit> habits,
  ) async {
    return [];
  }
}
