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

    final goodHabits = habits.where((h) => h.tipo != 'MAL_HABITO').toList();
    final badHabits = habits.where((h) => h.tipo == 'MAL_HABITO').toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateHabitModal(context),
        label: const Text('Nuevo Hábito'),
        icon: const Icon(Icons.add_rounded),
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
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildHabitListSection(
                      context,
                      goodHabits,
                      "Hábitos Positivos",
                      Icons.trending_up,
                      Colors.green,
                    ),
                    _buildHabitListSection(
                      context,
                      badHabits,
                      "Rompiendo Cadenas",
                      Icons.warning_amber_rounded,
                      Colors.orange,
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
      ),
    );
  }

  Widget _buildHabitListSection(
    BuildContext context,
    List<Habit> habits,
    String title,
    IconData icon,
    Color iconColor,
  ) {
    if (habits.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildSectionHeader(title, icon, iconColor),
          const SizedBox(height: 8),
          ...habits.map(
            (habit) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF25273A),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: HabitCard(habit: habit),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.flag_circle_outlined, size: 80, color: Colors.white24),
            const SizedBox(height: 20),
            const Text(
              '¡Es hora de empezar tu nueva rutina!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Presiona el botón "+" para crear tu primer hábito y comenzar a construir tu mejor versión.',
              style: TextStyle(fontSize: 16, color: Colors.white38),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateHabitModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B1D2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
