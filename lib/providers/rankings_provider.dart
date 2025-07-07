// lib/providers/rankings_provider.dart

import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

// Modelo simple para un usuario en el ranking.
// Podrías crear un archivo separado en /models si lo prefieres.
class RankedUser {
  final int userId;
  final String nombre;
  final String? fotoUrl;
  final int score;

  RankedUser({
    required this.userId,
    required this.nombre,
    this.fotoUrl,
    required this.score,
  });

  factory RankedUser.fromJson(Map<String, dynamic> json) {
    return RankedUser(
      userId: json['usuario_id'],
      nombre: json['nombre'],
      fotoUrl: json['foto_perfil_url'],
      score: json['valor'],
    );
  }
}

class RankingsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<RankedUser> _rankings = [];
  bool _isLoading = false;
  String _error = '';
  String _scope = 'global'; // El scope por defecto será 'global'

  // Getters para que la UI acceda al estado
  List<RankedUser> get rankings => _rankings;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get scope => _scope;

  RankingsProvider() {
    // Carga los rankings iniciales al crear el provider
    fetchRankings();
  }

  /// Carga los rankings desde la API según el scope actual.
  Future<void> fetchRankings() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final rankingsData = await _apiService.getRankings(scope: _scope);
      _rankings =
          rankingsData.map((data) => RankedUser.fromJson(data)).toList();
    } catch (e) {
      _error = e.toString();
      debugPrint("Error al cargar rankings: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cambia el scope y vuelve a cargar los datos.
  void setScope(String newScope) {
    if (_scope == newScope) return; // No hacer nada si el scope es el mismo

    _scope = newScope;
    notifyListeners();
    fetchRankings(); // Vuelve a cargar los datos con el nuevo scope
  }
}
