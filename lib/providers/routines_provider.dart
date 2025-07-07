// lib/providers/routines_provider.dart

import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

// Modelo simple para la rutina, puedes moverlo a su propio archivo en /models si prefieres
class Routine {
  final int id;
  final String nombre;
  final String? descripcion;
  final List<dynamic> habits; // Lista de hábitos asociados

  Routine({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.habits = const [],
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      habits: (json['habits'] as List<dynamic>?) ?? [],
    );
  }
}

class RoutinesProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Routine> _routines = [];
  Routine? _selectedRoutine;

  bool _isLoadingList = false;
  bool _isLoadingDetails = false;
  String? _error;

  // Getters para que la UI acceda al estado
  List<Routine> get routines => _routines;
  Routine? get selectedRoutine => _selectedRoutine;
  bool get isLoadingList => _isLoadingList;
  bool get isLoadingDetails => _isLoadingDetails;
  String? get error => _error;

  // --- MÉTODOS PARA INTERACTUAR CON LA API ---

  /// Carga la lista completa de rutinas del usuario.
  Future<void> fetchRoutines() async {
    _isLoadingList = true;
    _error = null;
    notifyListeners();

    try {
      final routinesData = await _apiService.getRoutines();
      _routines = routinesData.map((data) => Routine.fromJson(data)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  /// Crea una nueva rutina y la añade a la lista local.
  Future<bool> createRoutine(String nombre, String? descripcion) async {
    _isLoadingList = true; // Reusamos el loading de la lista
    notifyListeners();

    try {
      final newRoutineData = await _apiService.createRoutine(
        nombre,
        descripcion,
      );
      _routines.add(Routine.fromJson(newRoutineData));
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  /// Carga los detalles de una rutina específica.
  Future<void> fetchRoutineDetails(int routineId) async {
    _isLoadingDetails = true;
    _error = null;
    _selectedRoutine = null;
    notifyListeners();

    try {
      final routineData = await _apiService.getRoutineDetails(routineId);
      _selectedRoutine = Routine.fromJson(routineData);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  /// Añade un hábito a la rutina seleccionada actualmente.
  Future<bool> addHabitToSelectedRoutine(int habitId) async {
    if (_selectedRoutine == null) return false;

    try {
      await _apiService.addHabitToRoutine(_selectedRoutine!.id, habitId);
      // Recargamos los detalles para tener la lista de hábitos actualizada
      await fetchRoutineDetails(_selectedRoutine!.id);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Quita un hábito de la rutina seleccionada actualmente.
  Future<bool> removeHabitFromSelectedRoutine(int habitId) async {
    if (_selectedRoutine == null) return false;

    try {
      await _apiService.removeHabitFromRoutine(_selectedRoutine!.id, habitId);
      // Actualización optimista: lo quitamos de la lista local al instante
      _selectedRoutine!.habits.removeWhere((habit) => habit['id'] == habitId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      // Si falla, volvemos a cargar los datos para revertir el cambio
      await fetchRoutineDetails(_selectedRoutine!.id);
      return false;
    }
  }

  /// Elimina una rutina de la lista y llama a la API.
  Future<bool> deleteRoutine(int routineId) async {
    try {
      // Llamada a la API para eliminar en el backend
      await _apiService.deleteRoutine(routineId);

      // Actualización optimista: la quitamos de la lista local para una UI instantánea
      _routines.removeWhere((routine) => routine.id == routineId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      // Si falla, podrías considerar recargar la lista para asegurar la consistencia
      // await fetchRoutines();
      return false;
    }
  }
}
