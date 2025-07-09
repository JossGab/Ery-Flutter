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
                ? _buildEmptyState()
                : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildHabitListSection(
                      goodHabits,
                      "Hábitos Positivos",
                      Icons.trending_up,
                      Colors.greenAccent,
                    ),
                    _buildHabitListSection(
                      badHabits,
                      "Rompiendo Cadenas",
                      Icons.warning_amber_rounded,
                      Colors.orangeAccent,
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
      ),
    );
  }

  SliverPadding _buildHabitListSection(
    List<Habit> habits,
    String title,
    IconData icon,
    Color iconColor,
  ) {
    if (habits.isEmpty) {
      return const SliverPadding(
        padding: EdgeInsets.zero,
        sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildSectionHeader(title, icon, iconColor),
          const SizedBox(height: 12),
          ...habits.map((habit) => HabitCard(habit: habit)),
        ]),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color iconColor) {
    return Row(
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.flag_circle_outlined, size: 80, color: Colors.white24),
            SizedBox(height: 20),
            Text(
              '¡Es hora de empezar tu nueva rutina!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
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
      builder:
          (_) => ChangeNotifierProvider.value(
            value: Provider.of<AuthProvider>(context, listen: false),
            child: const CreateHabitModal(),
          ),
    );
  }
}
