/*
================================================================================
 ARCHIVO: lib/views/dashboard/widgets/habit_progress_section.dart (Rediseñado)
 INSTRUCCIONES: Reemplaza tu archivo con este.
 Concepto: "Enfoque del Día" - Tarjetas interactivas para completar hábitos.
================================================================================
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/habit_model.dart';
import '../../../providers/auth_provider.dart';

class HabitProgressSection extends StatelessWidget {
  final List<Habit> habits;

  const HabitProgressSection({super.key, required this.habits});

  void _logProgress(
    BuildContext context,
    Habit habit,
    Map<String, dynamic> payload,
  ) {
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
              content: Text('¡Bien hecho! Progreso registrado.'),
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
    if (habits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: const Center(
          child: Text(
            'Crea tu primer hábito para empezar a registrar tu progreso aquí.',
            style: TextStyle(color: Colors.white60),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Enfoque del Día",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: habits.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final habit = habits[index];
              return _HabitActionCard(
                habit: habit,
                onLog: (payload) => _logProgress(context, habit, payload),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HabitActionCard extends StatelessWidget {
  final Habit habit;
  final Function(Map<String, dynamic>) onLog;

  const _HabitActionCard({required this.habit, required this.onLog});

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
              style: const TextStyle(
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

  Widget _buildActionButton(BuildContext context) {
    switch (habit.tipo) {
      case 'SI_NO':
        return ElevatedButton.icon(
          onPressed: () => onLog({'valor_booleano': true}),
          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
          label: const Text("Hecho"),
          style: _buttonStyle(const Color(0xFF34D399)), // verde suave
        );
      case 'MAL_HABITO':
        return ElevatedButton.icon(
          onPressed: () => onLog({'es_recaida': true}),
          icon: const Icon(Icons.warning_amber_rounded, size: 18),
          label: const Text("Recaída"),
          style: _buttonStyle(const Color(0xFFFBBF24)), // amarillo suave
        );
      case 'MEDIBLE_NUMERICO':
        return ElevatedButton.icon(
          onPressed: () => _showNumericInputDialog(context),
          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
          label: const Text("Registrar"),
          style: _buttonStyle(const Color(0xFF60A5FA)), // azul suave
        );
      default:
        return const SizedBox.shrink();
    }
  }

  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color.withOpacity(0.15),
      foregroundColor: color,
      minimumSize: const Size.fromHeight(40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }

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
              style: const TextStyle(color: Colors.white),
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
                    onLog({'valor_numerico': value});
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
