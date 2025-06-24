// lib/views/dashboard/dashboard_view.dart - VERSIÓN CORREGIDA SIN DOBLE SIDEBAR

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- IMPORTS CORRECTOS ---
import 'widgets/stat_card.dart';
import 'widgets/dashboard_calendar.dart';
import 'widgets/habit_progress_section.dart';
import '../../providers/auth_provider.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0E0F1A),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _buildDashboardBody(authProvider),
      ),
    );
  }

  Widget _buildDashboardBody(AuthProvider authProvider) {
    if (authProvider.isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!authProvider.isAuthenticated) {
      return const Center(
        child: Text(
          'Sesión no válida. Por favor, inicia sesión de nuevo.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    if (authProvider.isLoading && authProvider.habits.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildMainContent(authProvider);
  }

  Widget _buildMainContent(AuthProvider authProvider) {
    final habits = authProvider.habits;

    if (habits.isEmpty && !authProvider.isLoading) {
      return const Center(
        child: Text(
          '¡Bienvenido! Crea tu primer hábito para empezar.',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    final activeHabitsCount = authProvider.activeHabitsCount;
    final bestStreak = authProvider.bestStreak;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mi Dashboard",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              StatCard(
                icon: Icons.bar_chart_rounded,
                title: "Hábitos Activos",
                value: "$activeHabitsCount",
              ),
              StatCard(
                icon: Icons.bolt_rounded,
                title: "Mejor Racha Actual",
                value: "$bestStreak días",
              ),
              const StatCard(
                icon: Icons.emoji_events_rounded,
                title: "Logros",
                value: "0",
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionContainer(
            title: "Progreso de Hábitos",
            child: HabitProgressSection(habits: []),
          ),
          _buildSectionContainer(
            title: "Calendario de Actividad",
            child: const DashboardCalendar(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1D2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
