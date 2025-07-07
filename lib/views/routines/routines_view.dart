// lib/views/routines/routines_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routines_provider.dart';
import 'create_routine_modal.dart';
import 'routine_detail_view.dart';

class RoutinesView extends StatefulWidget {
  const RoutinesView({super.key});

  @override
  State<RoutinesView> createState() => _RoutinesViewState();
}

class _RoutinesViewState extends State<RoutinesView> {
  @override
  void initState() {
    super.initState();
    // Le decimos al provider que cargue la lista de rutinas al abrir la pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoutinesProvider>().fetchRoutines();
    });
  }

  // --- MÉTODO ACTUALIZADO ---
  void _showCreateRoutineModal() {
    // Usamos showModalBottomSheet para mostrar el formulario desde abajo
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que el modal se ajuste al teclado
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateRoutineModal(),
    );
  }

  // --- MÉTODO ACTUALIZADO ---
  void _navigateToRoutineDetails(int routineId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoutineDetailView(routineId: routineId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateRoutineModal,
        label: const Text('Nueva Rutina'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Consumer<RoutinesProvider>(
        builder: (context, provider, child) {
          // Caso 1: Cargando
          if (provider.isLoadingList) {
            return const Center(child: CircularProgressIndicator());
          }

          // Caso 2: Error
          if (provider.error != null) {
            return Center(
              child: Text(
                'Ocurrió un error: ${provider.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          // Caso 3: Lista vacía
          if (provider.routines.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Aún no tienes rutinas.\nPresiona el botón "+" para crear la primera.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            );
          }

          // Caso 4: Mostrar la lista de rutinas
          return RefreshIndicator(
            onRefresh: () => provider.fetchRoutines(),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                80,
              ), // Padding inferior para el FAB
              itemCount: provider.routines.length,
              itemBuilder: (context, index) {
                final routine = provider.routines[index];
                return _RoutineCard(
                  routine: routine,
                  onTap: () => _navigateToRoutineDetails(routine.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// --- WIDGET INTERNO PARA LA TARJETA DE RUTINA ---
// Lo mantenemos aquí por ahora, pero podría moverse a /widgets/ si se reutiliza.
// --- WIDGET ACTUALIZADO PARA LA TARJETA DE RUTINA ---
class _RoutineCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;

  const _RoutineCard({required this.routine, required this.onTap});

  // Método para mostrar el diálogo de confirmación
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2937),
          title: const Text(
            'Confirmar Eliminación',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar la rutina "${routine.nombre}"? Esta acción no se puede deshacer.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.white60),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
              },
            ),
            TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                // Llama al provider para eliminar la rutina
                context.read<RoutinesProvider>().deleteRoutine(routine.id);
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1B1D2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const Icon(
                Icons.all_inclusive_rounded,
                color: Colors.blueAccent,
                size: 30,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      routine.nombre,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (routine.descripcion != null &&
                        routine.descripcion!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          routine.descripcion!,
                          style: const TextStyle(color: Colors.white70),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              // --- AÑADIDO: Botón para eliminar ---
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _showDeleteConfirmation(context),
                tooltip: 'Eliminar rutina',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
