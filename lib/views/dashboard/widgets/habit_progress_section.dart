import 'package:flutter/material.dart';

/// Un widget que muestra la sección de progreso de hábitos en el Dashboard.
///
/// Actualmente, muestra un mensaje de bienvenida si no hay hábitos.
/// En el futuro, se expandirá para mostrar la lista de hábitos del usuario.
class HabitProgressSection extends StatelessWidget {
  // En el futuro, recibiremos la lista de hábitos aquí.
  // final List<Habit> habits;
  const HabitProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Por ahora, asumimos que la lista de hábitos está vacía.
    const bool areHabitsEmpty = true;

    if (areHabitsEmpty) {
      return _buildEmptyState();
    } else {
      // TODO: Construir la lista de tarjetas de hábitos aquí.
      return const Text(
        "Aquí se mostrará la lista de hábitos.",
        style: TextStyle(color: Colors.white60),
      );
    }
  }

  /// Construye el widget que se muestra cuando el usuario no tiene hábitos.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "¡Es hora de empezar!\nAún no tienes hábitos para seguir.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar la navegación a la pantalla de "Crear Hábito".
              // Navigator.pushNamed(context, '/create-habit');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Crea tu primer hábito",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
