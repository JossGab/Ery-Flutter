/*
================================================================================
 ARCHIVO: lib/views/dashboard/dashboard_view.dart (Versión Completa y Mejorada)
================================================================================
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/stat_card.dart';
import 'widgets/dashboard_calendar.dart';
import 'widgets/motivational_card.dart';
import 'widgets/top_habits_section.dart';
import 'widgets/habit_progress_section.dart';

import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';

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
      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false).fetchDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (authProvider.isLoading && authProvider.habits.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0E0F1A),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0E0F1A),
      body: RefreshIndicator(
        onRefresh: () => authProvider.fetchDashboardData(),
        backgroundColor: const Color(0xFF1B1D2A),
        color: Colors.white,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Saludo
                    _buildWelcomeHeader(user),
                    const SizedBox(height: 24),

                    // Motivación
                    const MotivationalCard(),
                    const SizedBox(height: 32),

                    // Progreso del día
                    HabitProgressSection(habits: authProvider.habits),
                    const SizedBox(height: 36),

                    // Mejores hábitos
                    const Text(
                      "Top Hábitos",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TopHabitsSection(habits: authProvider.habits),
                    const SizedBox(height: 36),

                    // Estadísticas generales
                    const Text(
                      "Resumen General",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatsGrid(context, authProvider),
                    const SizedBox(height: 36),

                    // Calendario de actividad
                    const Text(
                      "Calendario de Actividad",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const DashboardCalendar(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(User? user) {
    final firstName = user?.name?.split(' ').first;
    return Row(
      children: [
        const Icon(Icons.waving_hand_rounded, color: Colors.amber, size: 28),
        const SizedBox(width: 10),
        Text(
          "Hola, ${firstName?.isNotEmpty == true ? firstName : 'Campeón'}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, AuthProvider authProvider) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildStatTile(
          context,
          icon: Icons.bar_chart_rounded,
          title: "Hábitos Activos",
          value: "${authProvider.activeHabitsCount}",
        ),
        _buildStatTile(
          context,
          icon: Icons.local_fire_department_rounded,
          title: "Mejor Racha",
          value: "${authProvider.bestStreak} días",
        ),
        _buildStatTile(
          context,
          icon: Icons.emoji_events_rounded,
          title: "Logros",
          value: "0/15",
        ),
        _buildStatTile(
          context,
          icon: Icons.check_circle_rounded,
          title: "Completados",
          value: "76%",
        ),
      ],
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width / 2) - 28,
      height: 110,
      child: StatCard(icon: icon, title: title, value: value),
    );
  }
}
