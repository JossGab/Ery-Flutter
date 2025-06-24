/*
================================================================================
 ARCHIVO: lib/views/habits/habits_view.dart
 INSTRUCCIONES: Este es el archivo principal de la vista.
 Se encarga de mostrar la lista de hábitos y de abrir el modal de creación.
================================================================================
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Ajusta las rutas de importación según tu estructura de carpetas
import '../../providers/auth_provider.dart';
import '../../models/habit_model.dart';
import 'widgets/habit_card.dart';
import 'widgets/create_habit_modal.dart';

class HabitsView extends StatelessWidget {
  const HabitsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos al AuthProvider para obtener la lista de hábitos
    final authProvider = context.watch<AuthProvider>();
    final habits = authProvider.habits;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Mis Hábitos'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Crear Hábito',
            onPressed: () => _showCreateHabitModal(context),
          ),
        ],
      ),
      body:
          authProvider.isLoading && habits.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh:
                    () => context.read<AuthProvider>().fetchDashboardData(),
                child:
                    habits.isEmpty
                        ? _buildEmptyState(context)
                        : _buildHabitsGrid(habits),
              ),
    );
  }

  // Muestra el modal para crear un nuevo hábito
  void _showCreateHabitModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B1D2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        // Es importante pasar el AuthProvider al modal para que pueda llamar a createHabit
        return ChangeNotifierProvider.value(
          value: Provider.of<AuthProvider>(context, listen: false),
          child: const CreateHabitModal(),
        );
      },
    );
  }

  // Widget para cuando no hay hábitos
  Widget _buildEmptyState(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.emoji_flags_outlined,
                    size: 60,
                    color: Colors.white38,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¡Es hora de empezar un nuevo reto!',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crea tu primer hábito usando el botón "+".',
                    style: TextStyle(color: Colors.white38),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget para mostrar la cuadrícula de hábitos
  Widget _buildHabitsGrid(List<Habit> habits) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.8,
      ),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        return HabitCard(habit: habits[index]);
      },
    );
  }
}
