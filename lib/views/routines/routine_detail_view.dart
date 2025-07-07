// lib/views/routines/routine_detail_view.dart

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
    // Cargamos los detalles de esta rutina específica al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutinesProvider>().fetchRoutineDetails(widget.routineId);
    });
  }

  // --- MÉTODO ACTUALIZADO ---
  void _showAddHabitModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        // Envolvemos el modal con el provider de rutinas para que tenga acceso
        // al 'selectedRoutine' y pueda llamar a los métodos necesarios.
        return ChangeNotifierProvider.value(
          value: context.read<RoutinesProvider>(),
          child: const AddHabitToRoutineModal(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos 'Consumer' para reaccionar a los cambios en el provider
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
                  ? const Center(child: Text('No se pudo cargar la rutina.'))
                  : _buildRoutineDetails(routine),
        );
      },
    );
  }

  Widget _buildRoutineDetails(Routine routine) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (routine.descripcion != null && routine.descripcion!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
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
        const SizedBox(height: 12),

        if (routine.habits.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              'Aún no hay hábitos en esta rutina. ¡Añade uno!',
              style: TextStyle(color: Colors.white54),
            ),
          ),

        ...routine.habits.map((habit) {
          return Card(
            color: const Color(0xFF1F2937),
            margin: const EdgeInsets.only(bottom: 8),
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
                  // Llama al método del provider para quitar el hábito
                  context
                      .read<RoutinesProvider>()
                      .removeHabitFromSelectedRoutine(habit['id']);
                },
              ),
            ),
          );
        }).toList(),

        const SizedBox(height: 80), // Espacio para el FAB
      ],
    );
  }
}
