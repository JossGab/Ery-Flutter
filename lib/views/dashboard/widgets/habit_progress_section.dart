/*
================================================================================
 ARCHIVO: lib/views/dashboard/widgets/habit_progress_section.dart (Rediseñado)
 INSTRUCCIONES: Reemplaza tu archivo con este.
 Concepto: "Enfoque del Día" - Tarjetas interactivas para completar hábitos.
================================================================================
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Ajusta las rutas según tu proyecto
import '../../../models/habit_model.dart';
import '../../../providers/auth_provider.dart';

class HabitProgressSection extends StatelessWidget {
  // CORRECCIÓN DE TIPO: Usamos el modelo Habit, no un Map.
  final List<Habit> habits;

  const HabitProgressSection({super.key, required this.habits});

  void _logProgress(
    BuildContext context,
    Habit habit,
    Map<String, dynamic> payload,
  ) {
    // Reutilizamos la lógica de logueo del AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Añadimos los datos necesarios para la API
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
    // TODO: En un futuro, aquí se debería filtrar por hábitos pendientes del día.
    // Por ahora, mostramos todos los hábitos activos.
    if (habits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Crea tu primer hábito para empezar a registrar tu progreso aquí.',
            style: TextStyle(color: Colors.white54),
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
          height: 140, // Altura fija para el carrusel horizontal
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

// Widget interno para cada tarjeta de acción
class _HabitActionCard extends StatelessWidget {
  final Habit habit;
  final Function(Map<String, dynamic>) onLog;

  const _HabitActionCard({required this.habit, required this.onLog});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2, // Proporción de la tarjeta
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1B1D2A),
          border: Border.all(color: Colors.white10),
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

  // Construye el botón de acción según el tipo de hábito
  Widget _buildActionButton(BuildContext context) {
    switch (habit.tipo) {
      case 'SI_NO':
        return ElevatedButton.icon(
          onPressed: () => onLog({'valor_booleano': true}),
          icon: const Icon(Icons.check, size: 18),
          label: const Text("Hecho"),
          style: _buttonStyle(Colors.green),
        );
      case 'MAL_HABITO':
        return ElevatedButton.icon(
          onPressed: () => onLog({'es_recaida': true}),
          icon: const Icon(Icons.warning_amber_rounded, size: 18),
          label: const Text("Recaída"),
          style: _buttonStyle(Colors.orange),
        );
      case 'MEDIBLE_NUMERICO':
        return ElevatedButton.icon(
          // Al presionarlo, podría abrir un mini-diálogo para ingresar el número
          onPressed: () => _showNumericInputDialog(context),
          icon: const Icon(Icons.add, size: 18),
          label: const Text("Registrar"),
          style: _buttonStyle(Colors.blue),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // Estilo base para los botones
  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color.withOpacity(0.2),
      foregroundColor: color,
      minimumSize: const Size.fromHeight(40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  // Diálogo para hábitos numéricos
  void _showNumericInputDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            backgroundColor: const Color(0xFF1B1D2A),
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
              decoration: InputDecoration(
                labelText: 'Valor (Meta: ${habit.metaObjetivo ?? 'N/A'})',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
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
