/*
================================================================================
 ARCHIVO: lib/views/habits/widgets/habit_card.dart
 INSTRUCCIONES: Este es el archivo con la corrección. 
 La función _logProgress ahora imprimirá los errores en la consola.
================================================================================
*/
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

// Ajusta las rutas de importación según tu estructura de carpetas
import '../../../models/habit_model.dart';
import '../../../providers/auth_provider.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  const HabitCard({super.key, required this.habit});

  // Helper para obtener la fecha de hoy en el formato que espera la API
  String get _todayStringForAPI =>
      DateFormat('yyyy-MM-dd').format(DateTime.now());

  // --- FUNCIÓN CORREGIDA ---
  void _logProgress(BuildContext context, Map<String, dynamic> payload) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Se define el payload fuera del 'try' para poder acceder a él en el 'catch'
    final logData = {
      'habito_id': habit.id,
      'fecha_registro': _todayStringForAPI,
      ...payload,
    };

    try {
      await authProvider.logHabitProgress(logData);
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('¡Progreso registrado!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e, stackTrace) {
      // Se captura el error (e) y el stackTrace

      // ======================= LA SOLUCIÓN ESTÁ AQUÍ =======================
      // Imprimimos toda la información del error en la consola de depuración.
      // Esto es lo que te permitirá ver el problema en VS Code.

      debugPrint('===== ERROR AL REGISTRAR PROGRESO DE HÁBITO =====');
      debugPrint('Hábito: ${habit.nombre} (ID: ${habit.id})');
      debugPrint('Payload enviado a la API: $logData');
      debugPrint('Error arrojado: $e');
      debugPrint('Stack Trace: $stackTrace');
      debugPrint('=====================================================');
      // =====================================================================

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString().replaceFirst("Exception: ", "")}',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color:
                habit.tipo == 'MAL_HABITO'
                    ? Colors.orange.shade700
                    : Colors.green.shade600,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            habit.nombre,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (habit.descripcion?.isNotEmpty ?? false)
            Text(
              habit.descripcion!,
              style: const TextStyle(color: Colors.white60),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const Spacer(),
          _buildActionWidget(context),
        ],
      ),
    );
  }

  // Widget que construye el botón de acción según el tipo de hábito
  Widget _buildActionWidget(BuildContext context) {
    switch (habit.tipo) {
      case 'SI_NO':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _logProgress(context, {'valor_booleano': true}),
            child: const Text('Marcar como Hecho'),
          ),
        );
      case 'MAL_HABITO':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _logProgress(context, {'es_recaida': true}),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent[100],
            ),
            child: const Text('Registrar Recaída'),
          ),
        );
      case 'MEDIBLE_NUMERICO':
        final controller = TextEditingController();
        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Valor (Meta: ${habit.metaObjetivo})',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.check_circle),
              onPressed: () {
                final value = double.tryParse(controller.text);
                if (value != null) {
                  _logProgress(context, {'valor_numerico': value});
                }
              },
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
