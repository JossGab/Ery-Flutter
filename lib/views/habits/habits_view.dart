// lib/views/habits/habits_view.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/auth_provider.dart';
import '../../models/habit_model.dart';
import 'widgets/habit_card.dart';
import 'widgets/create_habit_modal.dart';

class HabitsView extends StatefulWidget {
  const HabitsView({super.key});

  @override
  State<HabitsView> createState() => _HabitsViewState();
}

class _HabitsViewState extends State<HabitsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final habits = authProvider.habits;

    final goodHabits = habits.where((h) => h.tipo != 'MAL_HABITO').toList();
    final badHabits = habits.where((h) => h.tipo == 'MAL_HABITO').toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120.0),
        child: _buildAppBar(),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _HabitListPage(
            habits: goodHabits,
            emptyMessage:
                "Aún no tienes hábitos constructivos.\n¡Crea uno para empezar!",
            icon: Icons.rocket_launch_outlined,
          ),
          _HabitListPage(
            habits: badHabits,
            emptyMessage:
                "No estás rompiendo ninguna cadena.\n¡Define un mal hábito a superar!",
            icon: Icons.shield_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AppBar(
          backgroundColor: Colors.white.withOpacity(0.05),
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              '******',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            // --- INICIO DE LA CORRECCIÓN ---
            indicatorSize:
                TabBarIndicatorSize
                    .tab, // 1. Le decimos que ocupe toda la pestaña
            indicatorPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ), // 2. Mantenemos el padding que se ve bien
            indicator: BoxDecoration(
              // 3. El BoxDecoration se mantiene igual
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ),
            // --- FIN DE LA CORRECCIÓN ---
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.poppins(),
            tabs: const [
              Tab(text: 'Constructivos'),
              Tab(text: 'Rompiendo Cadenas'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showCreateHabitModal(context),
        label: Text(
          'Nuevo Hábito',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }

  void _showCreateHabitModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => ChangeNotifierProvider.value(
            value: Provider.of<AuthProvider>(context, listen: false),
            child: const CreateHabitModal(),
          ),
    );
  }
}

class _HabitListPage extends StatelessWidget {
  final List<Habit> habits;
  final String emptyMessage;
  final IconData icon;

  const _HabitListPage({
    required this.habits,
    required this.emptyMessage,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (habits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 80, color: Colors.white24),
                  const SizedBox(height: 20),
                  Text(
                    emptyMessage,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.8, 0.8)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => authProvider.fetchDashboardData(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];
          return HabitCard(habit: habit)
              .animate()
              .fadeIn(delay: (100 * index).ms, duration: 400.ms)
              .slideY(begin: 0.3, curve: Curves.easeOut);
        },
      ),
    );
  }
}
