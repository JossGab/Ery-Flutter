import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../models/habit_model.dart';

class TopHabitsSection extends StatelessWidget {
  final List<Habit> habits;

  const TopHabitsSection({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    final sortedHabits = List<Habit>.from(habits)
      ..sort((a, b) => b.rachaActual.compareTo(a.rachaActual));

    final topHabits = sortedHabits.take(3).toList();

    if (topHabits.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "🔥 Hábitos en Racha",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ListView.separated(
          itemCount: topHabits.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final habit = topHabits[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIconForHabitType(habit.tipo),
                        color: Colors.amberAccent,
                        size: 30,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.nombre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getLabelForHabitType(habit.tipo),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${habit.rachaActual} días",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getIconForHabitType(String type) {
    switch (type) {
      case 'SI_NO':
        return Icons.check_circle_outline;
      case 'MEDIBLE_NUMERICO':
        return Icons.straighten_rounded;
      case 'MAL_HABITO':
        return Icons.shield_outlined;
      default:
        return Icons.star_border_rounded;
    }
  }

  String _getLabelForHabitType(String type) {
    switch (type) {
      case 'SI_NO':
        return "Tipo: Sí / No";
      case 'MEDIBLE_NUMERICO':
        return "Tipo: Medible";
      case 'MAL_HABITO':
        return "Tipo: Mal hábito";
      default:
        return "Tipo desconocido";
    }
  }
}
