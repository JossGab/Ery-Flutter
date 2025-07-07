// lib/providers/competitions_provider.dart

import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class CompetitionsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // --- ESTADO DEL PROVIDER ---

  // Lista para las competencias del usuario
  List<dynamic> _myCompetitions = [];

  // Mapa para guardar los detalles de la competencia seleccionada
  Map<String, dynamic>? _selectedCompetitionDetails;

  bool _isLoadingList = false;
  bool _isLoadingDetails = false;
  String? _error;

  // --- GETTERS PÚBLICOS PARA LA UI ---

  List<dynamic> get myCompetitions => _myCompetitions;
  Map<String, dynamic>? get selectedCompetitionDetails =>
      _selectedCompetitionDetails;
  bool get isLoadingList => _isLoadingList;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get error => _error;

  // --- MÉTODOS PARA INTERACTUAR CON LA API ---

  /// Carga la lista de competencias en las que participa el usuario.
  Future<void> fetchMyCompetitions() async {
    _isLoadingList = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiService.getMyCompetitions();
      // La API devuelve un objeto con una clave "competitions"
      _myCompetitions = response['competitions'] ?? [];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  /// Carga los detalles y el leaderboard de una competencia específica.
  Future<void> fetchCompetitionDetails(int competitionId) async {
    _isLoadingDetails = true;
    _error = null;
    _selectedCompetitionDetails = null; // Limpiamos los detalles anteriores
    notifyListeners();
    try {
      final routineData = await _apiService.getCompetitionLeaderboard(
        competitionId,
      );

      // --- LÍNEA AÑADIDA PARA DEPURAR ---
      debugPrint("Respuesta completa del Leaderboard: $routineData");
      // --- FIN DE LA LÍNEA AÑADIDA ---
      _selectedCompetitionDetails = await _apiService.getCompetitionLeaderboard(
        competitionId,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  /// Crea una nueva competición.
  Future<bool> createCompetition(Map<String, dynamic> competitionData) async {
    // Usamos el loading de la lista para dar feedback en la UI principal
    _isLoadingList = true;
    notifyListeners();
    try {
      await _apiService.createCompetition(competitionData);
      // Tras crear, refrescamos la lista de competiciones
      await fetchMyCompetitions();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  /// Permite al usuario unirse a una competencia.
  Future<bool> joinCompetition(int competitionId) async {
    try {
      await _apiService.joinCompetition(competitionId);
      // Tras unirse, refrescamos los detalles para mostrar al usuario como participante
      await fetchCompetitionDetails(competitionId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
