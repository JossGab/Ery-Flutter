import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routines_provider.dart';
import '../../providers/auth_provider.dart';

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
    final allUserHabits = context.watch<AuthProvider>().habits;
    final selectedRoutine = context.watch<RoutinesProvider>().selectedRoutine;
    final habitIdsInRoutine =
        selectedRoutine?.habits.map((h) => h['id'] as int).toSet() ?? {};
    final availableHabits =
        allUserHabits
            .where((habit) => !habitIdsInRoutine.contains(habit.id))
            .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
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
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      '¡Felicidades! Todos tus hábitos ya están en esta rutina.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                else
                  DropdownButtonFormField<int>(
                    value: _selectedHabitId,
                    hint: const Text(
                      'Selecciona un hábito...',
                      style: TextStyle(color: Colors.white70),
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.07),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                    dropdownColor: const Color(0xFF2D3748),
                    style: const TextStyle(color: Colors.white),
                    onChanged:
                        (value) => setState(() => _selectedHabitId = value),
                    items:
                        availableHabits
                            .map(
                              (habit) => DropdownMenuItem<int>(
                                value: habit.id,
                                child: Text(habit.nombre),
                              ),
                            )
                            .toList(),
                  ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed:
                      (_selectedHabitId == null || _isLoading)
                          ? null
                          : _addHabit,
                  style: ElevatedButton.styleFrom(
                    elevation: 6,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                ),
              ],
            ),
          ),
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
