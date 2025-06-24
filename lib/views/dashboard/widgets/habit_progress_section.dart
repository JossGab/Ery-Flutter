// lib/views/dashboard/widgets/habit_progress_section.dart
import 'package:flutter/material.dart';

class HabitProgressSection extends StatelessWidget {
  // Lo preparamos para recibir la lista de hábitos
  final List<Map<String, dynamic>> habits;

  const HabitProgressSection({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return const Text(
        'No hay hábitos para mostrar.',
        style: TextStyle(color: Colors.white54),
      );
    }

    // Aquí construirías la lista de barras de progreso, etc.
    // Por ahora, solo mostramos el primer hábito como ejemplo.
    return ListTile(
      leading: Icon(Icons.check_circle_outline, color: Colors.green),
      title: Text(
        habits.first['nombre'],
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        'Racha: ${habits.first['racha_actual']} días',
        style: TextStyle(color: Colors.white70),
      ),
    );
  }
}
