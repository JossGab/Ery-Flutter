/*
================================================================================
 ARCHIVO: lib/views/habits/widgets/habit_card.dart (Versión Rediseñada)
================================================================================
*/
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/habit_model.dart';
import '../../../providers/auth_provider.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  const HabitCard({super.key, required this.habit});

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
    final isBadHabit = habit.tipo == 'MAL_HABITO';
    final accentColor = isBadHabit ? Colors.orangeAccent : Colors.greenAccent;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título, icono y racha
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      isBadHabit
                          ? Icons.warning_amber_rounded
                          : Icons.favorite_outline,
                      color: accentColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.nombre,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (habit.descripcion != null &&
                              habit.descripcion!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                habit.descripcion!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.amber,
                          size: 20,
                        ),
                        Text(
                          '${habit.rachaActual}d',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Barra de progreso si aplica
                if (habit.tipo == 'MEDIBLE_NUMERICO')
                  _buildProgressBar(habit, accentColor),

                const SizedBox(height: 20),

                // Botón
                _buildActionButton(context, accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(Habit habit, Color color) {
    double current = 3; // Ejemplo temporal
    double goal = habit.metaObjetivo?.toDouble() ?? 1;
    double percent = min(current / goal, 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progreso: $current / $goal',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, Color accentColor) {
    late String label;
    late VoidCallback onPressed;

    switch (habit.tipo) {
      case 'SI_NO':
        label = 'Marcar como Completado';
        onPressed = () => _logProgress(context, {'valor_booleano': true});
        break;
      case 'MAL_HABITO':
        label = 'Registrar Recaída';
        onPressed = () => _logProgress(context, {'es_recaida': true});
        break;
      case 'MEDIBLE_NUMERICO':
        label = 'Añadir Progreso';
        onPressed = () {
          // Aquí podrías abrir un diálogo personalizado
        };
        break;
      default:
        return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: accentColor.withOpacity(0.85),
          elevation: 6,
          shadowColor: accentColor.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}
