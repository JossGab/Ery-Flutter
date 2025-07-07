// lib/views/routines/add_habit_to_routine_modal.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routines_provider.dart';
import '../../providers/auth_provider.dart'; // Necesitamos este para la lista completa de hábitos

class AddHabitToRoutineModal extends StatefulWidget {
  const AddHabitToRoutineModal({super.key});

  @override
  State<AddHabitToRoutineModal> createState() => _AddHabitToRoutineModalState();
}

class _AddHabitToRoutineModalState extends State<AddHabitToRoutineModal> {
  int? _selectedHabitId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Obtenemos la lista de TODOS los hábitos del usuario desde AuthProvider
    final allUserHabits = context.watch<AuthProvider>().habits;

    // Obtenemos la rutina seleccionada actualmente desde RoutinesProvider
    final selectedRoutine = context.watch<RoutinesProvider>().selectedRoutine;

    // Creamos una lista de IDs de los hábitos que YA ESTÁN en la rutina
    final habitIdsInRoutine =
        selectedRoutine?.habits.map((h) => h['id'] as int).toSet() ?? {};

    // Filtramos la lista completa para mostrar solo los hábitos que NO ESTÁN en la rutina
    final availableHabits =
        allUserHabits.where((habit) {
          return !habitIdsInRoutine.contains(habit.id);
        }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: const BoxDecoration(
          color: Color(0xFF1B1D2A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Añadir Hábito a la Rutina',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            if (availableHabits.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  '¡Felicidades! Todos tus hábitos ya están en esta rutina.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              )
            else
              // Usamos un Dropdown para seleccionar el hábito
              DropdownButtonFormField<int>(
                value: _selectedHabitId,
                hint: const Text(
                  'Selecciona un hábito...',
                  style: TextStyle(color: Colors.white70),
                ),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Color(0xFF2D3748),
                ),
                dropdownColor: const Color(0xFF2D3748),
                style: const TextStyle(color: Colors.white),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedHabitId = newValue;
                  });
                },
                items:
                    availableHabits.map((habit) {
                      return DropdownMenuItem<int>(
                        value: habit.id,
                        child: Text(habit.nombre),
                      );
                    }).toList(),
              ),

            const SizedBox(height: 24),
            ElevatedButton(
              // El botón se deshabilita si no se ha seleccionado un hábito o si ya no hay hábitos disponibles
              onPressed:
                  (_selectedHabitId == null || _isLoading) ? null : _addHabit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Text(
                        'Añadir Hábito',
                        style: TextStyle(color: Colors.white),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addHabit() async {
    if (_selectedHabitId == null) return;

    setState(() => _isLoading = true);

    final routinesProvider = context.read<RoutinesProvider>();
    final success = await routinesProvider.addHabitToSelectedRoutine(
      _selectedHabitId!,
    );

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: ${routinesProvider.error ?? 'No se pudo añadir el hábito'}",
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }
}
