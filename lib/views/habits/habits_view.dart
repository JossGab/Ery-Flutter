/*
================================================================================
 ARCHIVO: lib/views/habits/habits_view.dart (Versión Rediseñada)
 INSTRUCCIONES: Se agrupan los hábitos por tipo para una mejor organización.
================================================================================
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../models/habit_model.dart';
import 'widgets/habit_card.dart';
import 'widgets/create_habit_modal.dart';

class HabitsView extends StatelessWidget {
  const HabitsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final habits = authProvider.habits;

    // Lógica para separar los hábitos por tipo
    final goodHabits = habits.where((h) => h.tipo != 'MAL_HABITO').toList();
    final badHabits = habits.where((h) => h.tipo == 'MAL_HABITO').toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Usamos un FloatingActionButton para "Crear Hábito", un patrón más estándar
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateHabitModal(context),
        label: const Text('Nuevo Hábito'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<AuthProvider>().fetchDashboardData(),
        child:
            authProvider.isLoading && habits.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : habits.isEmpty
                ? _buildEmptyState(context)
                : CustomScrollView(
                  slivers: [
                    // Usamos un SliverAppBar para un efecto de encogimiento más elegante
                    const SliverAppBar(
                      title: Text('Mis Hábitos'),
                      backgroundColor: Colors.transparent,
                      pinned: true,
                      centerTitle: false,
                    ),
                    // Mostramos la lista de hábitos con las secciones
                    _buildHabitList(context, goodHabits, badHabits),
                  ],
                ),
      ),
    );
  }

  // Widget principal que construye la lista de hábitos por secciones
  Widget _buildHabitList(
    BuildContext context,
    List<Habit> goodHabits,
    List<Habit> badHabits,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        80,
      ), // Padding para no chocar con el FAB
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Sección de Buenos Hábitos
          if (goodHabits.isNotEmpty) ...[
            _buildSectionHeader(
              "Hábitos Positivos",
              Icons.trending_up,
              Colors.green,
            ),
            ...goodHabits.map(
              (habit) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: AspectRatio(
                  aspectRatio: 16 / 10, // Proporción para la tarjeta
                  child: HabitCard(habit: habit),
                ),
              ),
            ),
          ],

          // Sección de Malos Hábitos
          if (badHabits.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionHeader(
              "Rompiendo Cadenas",
              Icons.shield,
              Colors.orange,
            ),
            ...badHabits.map(
              (habit) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: HabitCard(habit: habit),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }

  // Widget para los encabezados de cada sección
  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // El estado vacío no necesita cambios
  Widget _buildEmptyState(BuildContext context) {
    return Center(
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
    );
  }

  // El modal tampoco necesita cambios
  void _showCreateHabitModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B1D2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return ChangeNotifierProvider.value(
          value: Provider.of<AuthProvider>(context, listen: false),
          child: const CreateHabitModal(),
        );
      },
    );
  }
}
