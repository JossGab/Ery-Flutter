import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement_model.dart';
import '../models/habit_model.dart';
import 'package:flutter/material.dart';

class AchievementService {
  // Lista Maestra de todos los logros posibles en la app
  final List<Achievement> _allAchievements = [
    Achievement(
      id: 'novato',
      title: 'Novato con Potencial',
      description: 'Crea tu primer hábito.',
      icon: Icons.star_border,
    ),
    Achievement(
      id: 'imparable',
      title: 'Imparable',
      description: 'Completa 5 hábitos en un solo día.',
      icon: Icons.whatshot,
    ),
    Achievement(
      id: 'racha_7',
      title: 'Racha de Fuego',
      description: 'Mantén una racha de 7 días en cualquier hábito.',
      icon: Icons.local_fire_department,
    ),
    Achievement(
      id: 'constante',
      title: 'Constancia Pura',
      description: 'Crea 5 hábitos diferentes.',
      icon: Icons.playlist_add_check,
    ),
    // ... aquí se pueden añadir muchos más
  ];

  List<Achievement> get allAchievements => _allAchievements;

  // Cargar los logros desbloqueados desde el almacenamiento local
  Future<void> loadUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedIds = prefs.getStringList('unlocked_achievements') ?? [];

    for (var achievement in _allAchievements) {
      if (unlockedIds.contains(achievement.id)) {
        achievement.isUnlocked = true;
      }
    }
  }

  // Verificar y desbloquear nuevos logros basados en los datos del usuario
  Future<List<Achievement>> checkAndUnlockAchievements(
    List<Habit> habits,
  ) async {
    final newUnlocked = <Achievement>[];

    // Recargamos el estado actual por si acaso
    await loadUnlockedAchievements();

    // Lógica de verificación para cada logro
    // Ejemplo para 'novato'
    final novato = _allAchievements.firstWhere((a) => a.id == 'novato');
    if (!novato.isUnlocked && habits.isNotEmpty) {
      _unlock(novato);
      newUnlocked.add(novato);
    }

    // Ejemplo para 'constante'
    final constante = _allAchievements.firstWhere((a) => a.id == 'constante');
    if (!constante.isUnlocked && habits.length >= 5) {
      _unlock(constante);
      newUnlocked.add(constante);
    }

    // Ejemplo para 'racha_7'
    final racha7 = _allAchievements.firstWhere((a) => a.id == 'racha_7');
    if (!racha7.isUnlocked && habits.any((h) => h.rachaActual >= 7)) {
      _unlock(racha7);
      newUnlocked.add(racha7);
    }

    // Devolvemos la lista de logros recién desbloqueados para mostrar una notificación
    return newUnlocked;
  }

  // Función privada para guardar un logro como desbloqueado
  Future<void> _unlock(Achievement achievement) async {
    if (achievement.isUnlocked) return;

    achievement.isUnlocked = true;
    final prefs = await SharedPreferences.getInstance();
    final unlockedIds = prefs.getStringList('unlocked_achievements') ?? [];
    if (!unlockedIds.contains(achievement.id)) {
      unlockedIds.add(achievement.id);
      await prefs.setStringList('unlocked_achievements', unlockedIds);
    }
  }
}
