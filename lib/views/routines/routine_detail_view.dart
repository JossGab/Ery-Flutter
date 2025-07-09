import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routines_provider.dart';
import 'add_habit_to_routine_modal.dart';

class RoutineDetailView extends StatefulWidget {
  final int routineId;

  const RoutineDetailView({super.key, required this.routineId});

  @override
  State<RoutineDetailView> createState() => _RoutineDetailViewState();
}

class _RoutineDetailViewState extends State<RoutineDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutinesProvider>().fetchRoutineDetails(widget.routineId);
    });
  }

  void _showAddHabitModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ChangeNotifierProvider.value(
          value: context.read<RoutinesProvider>(),
          child: const AddHabitToRoutineModal(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoutinesProvider>(
      builder: (context, provider, child) {
        final routine = provider.selectedRoutine;

        return Scaffold(
          backgroundColor: const Color(0xFF0E0F1A),
          appBar: AppBar(
            title: Text(
              provider.isLoadingDetails
                  ? 'Cargando...'
                  : routine?.nombre ?? 'Detalle de Rutina',
            ),
            backgroundColor: const Color(0xFF1B1D2A),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddHabitModal,
            label: const Text('Añadir Hábito'),
            icon: const Icon(Icons.add),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          body:
              provider.isLoadingDetails
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null
                  ? Center(
                    child: Text(
                      'Error: ${provider.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                  : routine == null
                  ? const Center(
                    child: Text(
                      'No se pudo cargar la rutina.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                  : _buildRoutineDetails(routine),
        );
      },
    );
  }

  Widget _buildRoutineDetails(Routine routine) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        if (routine.descripcion != null && routine.descripcion!.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: Text(
              routine.descripcion!,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        const Text(
          'Hábitos en esta Rutina',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        if (routine.habits.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'Aún no hay hábitos en esta rutina. ¡Añade uno!',
              style: TextStyle(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...routine.habits.map(
            (habit) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: ListTile(
                title: Text(
                  habit['nombre'],
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    context
                        .read<RoutinesProvider>()
                        .removeHabitFromSelectedRoutine(habit['id']);
                  },
                ),
              ),
            ),
          ),
        const SizedBox(height: 80),
      ],
    );
  }
}
