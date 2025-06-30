/*
================================================================================
 ARCHIVO: lib/views/habits/widgets/habit_card.dart (Versión Rediseñada)
================================================================================
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../../models/habit_model.dart';
import '../../../providers/auth_provider.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  const HabitCard({super.key, required this.habit});

  // Función para registrar el progreso (lógica movida aquí para reutilización)
  void _logProgress(BuildContext context, Map<String, dynamic> payload) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final logData = {
      'habito_id': habit.id,
      'fecha_registro': DateTime.now().toIso8601String().substring(0, 10),
      ...payload,
    };

    authProvider
        .logHabitProgress(logData)
        .then((_) {
          scaffoldMessenger.showSnackBar(
            const SnackBar(
              content: Text('¡Progreso actualizado!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        })
        .catchError((error) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                'Error: ${error.toString().replaceFirst("Exception: ", "")}',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final bool isBadHabit = habit.tipo == 'MAL_HABITO';
    final Color accentColor =
        isBadHabit ? Colors.orange.shade400 : Colors.green.shade400;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior con icono, título y racha
            Row(
              children: [
                Icon(
                  isBadHabit
                      ? Icons.shield_outlined
                      : Icons.check_circle_outline,
                  color: accentColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    habit.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.amber.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${habit.rachaActual} días',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Descripción (si existe)
            if (habit.descripcion != null && habit.descripcion!.isNotEmpty)
              Text(
                habit.descripcion!,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            const Spacer(),

            // Barra de progreso (para hábitos numéricos)
            if (habit.tipo == 'MEDIBLE_NUMERICO')
              _buildProgressBar(habit, accentColor),

            // Botones de acción
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  // Widget para la barra de progreso
  Widget _buildProgressBar(Habit habit, Color color) {
    // TODO: Necesitarías obtener el progreso actual desde la API para este día.
    // Por ahora, simulamos un valor.
    double currentProgress = 3; // Valor de ejemplo
    double goal = habit.metaObjetivo?.toDouble() ?? 1.0;
    double progressPercent = min(currentProgress / goal, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progreso', style: TextStyle(color: Colors.white70)),
              Text(
                '$currentProgress / $goal',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progressPercent,
            backgroundColor: Colors.grey.shade700,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  // Widget para los botones de acción
  Widget _buildActionButtons(BuildContext context) {
    if (habit.tipo == 'SI_NO') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _logProgress(context, {'valor_booleano': true}),
          child: const Text('Marcar como Completado'),
        ),
      );
    }

    if (habit.tipo == 'MAL_HABITO') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _logProgress(context, {'es_recaida': true}),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.withOpacity(0.8),
          ),
          child: const Text('Registrar Recaída'),
        ),
      );
    }

    if (habit.tipo == 'MEDIBLE_NUMERICO') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            /* Lógica para abrir diálogo de entrada numérica */
          },
          child: const Text('Añadir Progreso'),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
