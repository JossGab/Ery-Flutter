import 'dart:ui';
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
                    _buildWelcomeHeader(user),
                    const SizedBox(height: 24),
                    const MotivationalCard(),
                    const SizedBox(height: 32),
                    HabitProgressSection(habits: authProvider.habits),
                    const SizedBox(height: 36),
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
      height: 120,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueAccent.withOpacity(0.3),
                        Colors.indigo.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.blueAccent, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
