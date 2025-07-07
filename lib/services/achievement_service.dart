// lib/services/achievement_service.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/achievement_model.dart';

class AchievementService with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Achievement> _achievements = [];
  bool _isLoading = false;
  String? _error;

  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAchievements() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final achievementsData = await _apiService.getAchievements();

      _achievements =
          achievementsData.map((data) {
            // CORRECCIÓN: Guardamos la URL directamente en el modelo
            return Achievement(
              id: data['id'].toString(),
              title: data['nombre'],
              description: data['descripcion'],
              iconUrl:
                  data['icono_url'], // <-- CORREGIDO: Ya no se llama a _getIconFromString
              isUnlocked: data['unlocked'] ?? false,
            );
          }).toList();
    } catch (e) {
      _error = e.toString();
      debugPrint("Error al cargar logros: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CORRECCIÓN: La función _getIconFromString se elimina, ya no es necesaria.
}
