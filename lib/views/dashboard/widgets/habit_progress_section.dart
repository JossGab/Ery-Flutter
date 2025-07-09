// lib/views/dashboard/widgets/habit_progress_section.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../models/habit_model.dart';
import '../../../providers/auth_provider.dart';
// Importamos el diálogo de éxito que ya creamos
import '../../../widgets/common/success_dialog.dart';

/// Muestra una lista horizontal de hábitos para registrar el progreso del día.
class HabitProgressSection extends StatelessWidget {
  final List<Habit> habits;

  const HabitProgressSection({super.key, required this.habits});

  /// Registra el progreso, muestra el diálogo de éxito y actualiza el estado.
  void _completeHabit(
    BuildContext context,
    Habit habit,
    Map<String, dynamic> payload,
  ) {
    final authProvider = context.read<AuthProvider>();
    final logData = {
      'habito_id': habit.id,
      'fecha_registro': DateTime.now().toIso8601String().substring(0, 10),
      ...payload,
    };

    authProvider
        .logHabitProgress(logData)
        .then((_) {
          // Éxito: Muestra el diálogo y actualiza la UI al instante.
          showSuccessDialog(context, habit.nombre);
          authProvider.markHabitAsCompleted(habit.id);
        })
        .catchError((error) {
          // Error: Muestra un SnackBar con el mensaje de error.
          ScaffoldMessenger.of(context).showSnackBar(
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
    if (habits.isEmpty) {
      // Muestra un mensaje si no hay hábitos creados.
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          'Crea tu primer hábito para empezar a registrar tu progreso aquí.',
          style: GoogleFonts.poppins(color: Colors.white60),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "✨ Enfoque del Día",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: habits.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final habit = habits[index];
              return _HabitActionCard(
                habit: habit,
                // Pasamos la función _completeHabit al widget hijo.
                onComplete:
                    (payload) => _completeHabit(context, habit, payload),
              ).animate().fadeIn(duration: 500.ms).slideX(begin: 0.2);
            },
          ),
        ),
      ],
    );
  }
}

/// Widget interno para la tarjeta de acción de un hábito en el dashboard.
class _HabitActionCard extends StatelessWidget {
  final Habit habit;
  final Function(Map<String, dynamic>) onComplete;

  const _HabitActionCard({required this.habit, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              habit.nombre,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }

  /// Construye el botón de acción correcto según el estado y tipo del hábito.
  Widget _buildActionButton(BuildContext context) {
    // 1. Si el hábito ya fue completado, muestra un botón deshabilitado.
    if (habit.completadoHoy) {
      return ElevatedButton.icon(
        onPressed: null, // Botón deshabilitado
        icon: const Icon(Icons.check, size: 18),
        label: const Text("Completado"),
        style: _buttonStyle(Colors.grey.shade700).copyWith(
          // Estilo específico para el estado deshabilitado.
          backgroundColor: MaterialStateProperty.all(
            Colors.green.withOpacity(0.2),
          ),
          foregroundColor: MaterialStateProperty.all(
            Colors.white.withOpacity(0.7),
          ),
        ),
      );
    }

    // 2. Si no, muestra el botón de acción correspondiente.
    switch (habit.tipo) {
      case 'SI_NO':
        return ElevatedButton.icon(
          onPressed: () => onComplete({'valor_booleano': true}),
          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
          label: const Text("Hecho"),
          style: _buttonStyle(const Color(0xFF34D399)),
        );
      case 'MAL_HABITO':
        return ElevatedButton.icon(
          onPressed: () => onComplete({'es_recaida': true}),
          icon: const Icon(Icons.warning_amber_rounded, size: 18),
          label: const Text("Recaída"),
          style: _buttonStyle(const Color(0xFFFBBF24)),
        );
      case 'MEDIBLE_NUMERICO':
        return ElevatedButton.icon(
          onPressed: () => _showNumericInputDialog(context),
          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
          label: const Text("Registrar"),
          style: _buttonStyle(const Color(0xFF60A5FA)),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// Estilo base para los botones de acción.
  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color.withOpacity(0.15),
      foregroundColor: color,
      minimumSize: const Size.fromHeight(40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
    );
  }

  /// Muestra un diálogo para que el usuario ingrese un valor numérico.
  void _showNumericInputDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: const Color(0xFF1F2235).withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Registrar ${habit.nombre}',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            content: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Valor (Meta: ${habit.metaObjetivo ?? 'N/A'})',
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              FilledButton(
                onPressed: () {
                  final value = double.tryParse(controller.text);
                  if (value != null) {
                    // Llama a la función onComplete con el valor numérico.
                    onComplete({'valor_numerico': value});
                    Navigator.pop(dialogContext);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }
}
