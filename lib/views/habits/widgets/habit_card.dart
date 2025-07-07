/*
================================================================================
 ARCHIVO: lib/views/habits/widgets/habit_card.dart (Versión con CRUD completo)
================================================================================
*/
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/habit_model.dart';
import '../../../providers/auth_provider.dart';
import 'edit_habit_modal.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  const HabitCard({super.key, required this.habit});

  // --- LÓGICA PARA EL MENÚ DE OPCIONES ---

  /// Muestra el menú inferior con las opciones para editar o eliminar.
  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2937),
      builder:
          (_) => Wrap(
            children: <Widget>[
              // ===== OPCIÓN DE EDITAR COMENTADA =====
              // ListTile(
              //   leading: const Icon(Icons.edit_outlined, color: Colors.white70),
              //   title: const Text(
              //     'Editar Hábito',
              //     style: TextStyle(color: Colors.white),
              //   ),
              //   onTap: () {
              //     Navigator.of(context).pop(); // Cierra el menú
              //     _showEditModal(context); // Abre el modal de edición
              //   },
              // ),
              // =======================================
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Eliminar Hábito',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  Navigator.of(context).pop(); // Cierra el menú
                  _showDeleteConfirmation(context); // Muestra la confirmación
                },
              ),
            ],
          ),
    );
  }

  /// Abre el modal para editar el hábito.
  void _showEditModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        // Pasamos el hábito actual al modal de edición
        return EditHabitModal(habit: habit);
      },
    );
  }

  /// Muestra el diálogo de confirmación antes de eliminar un hábito.
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1F2937),
            title: const Text(
              'Confirmar Eliminación',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              '¿Estás seguro de que quieres eliminar el hábito "${habit.nombre}"? Esta acción no se puede deshacer.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white60),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  // Llama al provider para eliminar el hábito
                  context.read<AuthProvider>().deleteHabit(habit.id);
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
    );
  }

  void _logProgress(BuildContext context, Map<String, dynamic> payload) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final logData = {
      'habito_id': habit.id,
      'fecha_registro': DateTime.now().toIso8601String().substring(0, 10),
      ...payload,
    };
    authProvider.logHabitProgress(logData).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.toString()}'),
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
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      isBadHabit
                          ? Icons.shield_outlined
                          : Icons.favorite_border,
                      color: accentColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        habit.nombre,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
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
                    // --- AÑADIDO: Botón de menú ---
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white54),
                      onPressed: () => _showOptions(context),
                    ),
                  ],
                ),

                if (habit.descripcion != null && habit.descripcion!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 40,
                      right: 20,
                      top: 4,
                      bottom: 8,
                    ),
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

                const Spacer(),

                if (habit.tipo == 'MEDIBLE_NUMERICO')
                  _buildProgressBar(habit, accentColor),

                const SizedBox(height: 12),
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
