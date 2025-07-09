// lib/views/habits/widgets/habit_card.dart

import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/habit_model.dart';
import '../../../providers/auth_provider.dart';
import 'edit_habit_modal.dart';
// Importa el diálogo de éxito que creamos
import '../../../widgets/common/success_dialog.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  const HabitCard({super.key, required this.habit});

  /// Muestra el modal para editar el hábito.
  void _showEditModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) =>
          // Pasamos el AuthProvider al modal para que pueda actualizar el estado
          ChangeNotifierProvider.value(
            value: context.read<AuthProvider>(),
            child: EditHabitModal(habit: habit),
          ),
    );
  }

  /// Muestra la confirmación para eliminar el hábito.
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
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
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () {
                  // Usamos el AuthProvider para eliminar el hábito
                  context.read<AuthProvider>().deleteHabit(habit.id);
                  Navigator.pop(context);
                },
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  /// Muestra el menú de opciones (Editar/Eliminar).
  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1F2937),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white70,
                  ),
                  title: const Text(
                    'En construccion',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditModal(context);
                  },
                ),
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
                    Navigator.pop(context);
                    _showDeleteConfirmation(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  /// Registra el progreso, muestra el diálogo y actualiza el estado.
  void _completeHabit(BuildContext context, Map<String, dynamic> payload) {
    final authProvider = context.read<AuthProvider>();
    final logData = {
      'habito_id': habit.id,
      'fecha_registro': DateTime.now().toIso8601String().substring(0, 10),
      ...payload,
    };

    authProvider
        .logHabitProgress(logData)
        .then((_) {
          // Éxito: Muestra el diálogo y actualiza la UI
          showSuccessDialog(context, habit.nombre);
          authProvider.markHabitAsCompleted(habit.id);
        })
        .catchError((e) {
          // Error: Muestra un SnackBar con el mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, isBadHabit, accentColor),
                if (habit.descripcion != null && habit.descripcion!.isNotEmpty)
                  _buildDescription(),
                if (habit.tipo == 'MEDIBLE_NUMERICO')
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: _buildProgressBar(habit, accentColor),
                  ),
                const SizedBox(height: 14),
                _buildActionButton(context, accentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isBadHabit,
    Color accentColor,
  ) {
    return Row(
      children: [
        Icon(
          isBadHabit ? Icons.shield_outlined : Icons.favorite_border,
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
        const Icon(Icons.local_fire_department, color: Colors.amber, size: 20),
        const SizedBox(width: 4),
        Text(
          '${habit.rachaActual}d',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white60),
          onPressed: () => _showOptions(context),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.only(left: 40, top: 8, bottom: 8),
      child: Text(
        habit.descripcion!,
        style: const TextStyle(color: Colors.white70, fontSize: 14),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildProgressBar(Habit habit, Color color) {
    // Aquí puedes conectar el progreso real si lo tienes, por ahora usamos un valor de prueba
    double currentProgress = 0; // Deberías obtener este valor del estado
    double goal = habit.metaObjetivo?.toDouble() ?? 1;
    double percent = goal > 0 ? min(currentProgress / goal, 1) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progreso: $currentProgress / $goal',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
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

  /// Decide qué botón mostrar basado en el tipo de hábito y si ya fue completado.
  Widget _buildActionButton(BuildContext context, Color accentColor) {
    // --- LÓGICA PRINCIPAL ---
    // 1. Si el hábito ya fue completado, muestra un botón deshabilitado.
    if (habit.completadoHoy) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: null, // null deshabilita el botón
          icon: const Icon(Icons.check_circle_rounded),
          label: const Text('Completado Hoy'),
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Colors.green.withOpacity(0.2),
            disabledForegroundColor: Colors.white.withOpacity(0.7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
    }

    // 2. Si no, muestra el botón de acción correspondiente.
    late String label;
    late VoidCallback onPressed;

    switch (habit.tipo) {
      case 'SI_NO':
        label = 'Marcar como Completado';
        onPressed = () => _completeHabit(context, {'valor_booleano': true});
        break;
      case 'MAL_HABITO':
        label = 'Registrar Recaída';
        onPressed = () => _completeHabit(context, {'es_recaida': true});
        break;
      case 'MEDIBLE_NUMERICO':
        label = 'Añadir Progreso';
        onPressed = () {
          // Lógica para mostrar un diálogo y obtener el valor numérico
          // ...
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
          backgroundColor: accentColor.withOpacity(0.9),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 8,
          shadowColor: accentColor.withOpacity(0.5),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
