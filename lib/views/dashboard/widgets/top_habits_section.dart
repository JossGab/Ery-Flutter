import 'package:flutter/material.dart';
import '../../../models/habit_model.dart'; // Asegúrate que la ruta es correcta

class TopHabitsSection extends StatelessWidget {
  final List<Habit> habits;

  const TopHabitsSection({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    // Ordenamos los hábitos por racha de mayor a menor
    final sortedHabits = List<Habit>.from(habits)
      ..sort((a, b) => b.rachaActual.compareTo(a.rachaActual));

    // Tomamos los 3 mejores o menos si no hay tantos
    final topHabits = sortedHabits.take(3).toList();

    if (topHabits.isEmpty) {
      return const SizedBox.shrink(); // No mostrar nada si no hay hábitos
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Hábitos en Racha 🔥",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Usamos un ListView para que sea adaptable
        ListView.separated(
          itemCount: topHabits.length,
          shrinkWrap:
              true, // Para que el ListView ocupe solo el espacio necesario
          physics:
              const NeverScrollableScrollPhysics(), // Para que no scrollee dentro del SingleChildScrollView
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final habit = topHabits[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Icono del hábito
                  Icon(
                    _getIconForHabitType(habit.tipo),
                    color: Colors.amber.shade600,
                  ),
                  const SizedBox(width: 16),
                  // Nombre del hábito
                  Expanded(
                    child: Text(
                      habit.nombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Racha
                  Text(
                    "${habit.rachaActual} días",
                    style: TextStyle(
                      color: Colors.amber.shade400,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Pequeña función helper para obtener un icono según el tipo de hábito
  IconData _getIconForHabitType(String type) {
    switch (type) {
      case 'SI_NO':
        return Icons.check_circle_outline_rounded;
      case 'MEDIBLE_NUMERICO':
        return Icons.straighten_rounded;
      case 'MAL_HABITO':
        return Icons.shield_outlined;
      default:
        return Icons.star_border_rounded;
    }
  }
}
