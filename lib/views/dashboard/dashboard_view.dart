/*
================================================================================
 ARCHIVO: lib/views/dashboard/dashboard_view.dart (Versión Completa y Mejorada)
================================================================================
*/
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importación de todos nuestros widgets personalizados del dashboard
import 'widgets/stat_card.dart';
import 'widgets/dashboard_calendar.dart';
import 'widgets/motivational_card.dart';
import 'widgets/top_habits_section.dart';
import 'widgets/habit_progress_section.dart'; // El carrusel interactivo

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
    // Llamada inicial para cargar los datos del dashboard de forma segura.
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

    // Muestra un indicador de carga central mientras se obtienen los datos iniciales.
    if (authProvider.isLoading && authProvider.habits.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF0E0F1A),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0E0F1A),
      // El RefreshIndicator permite al usuario "tirar para actualizar".
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
                    const SizedBox(
                      height: 48,
                    ), // Espacio superior para la barra de estado
                    // --- ESTRUCTURA DEL DASHBOARD REDISEÑADO ---

                    // 1. Saludo personalizado
                    _buildWelcomeHeader(user),
                    const SizedBox(height: 24),

                    // 2. Tarjeta de Motivación
                    const MotivationalCard(),
                    const SizedBox(height: 32),

                    // 3. Sección Interactiva "Enfoque del Día"
                    HabitProgressSection(habits: authProvider.habits),
                    const SizedBox(height: 32),

                    // 4. Sección de Hábitos con mejores rachas
                    TopHabitsSection(habits: authProvider.habits),
                    const SizedBox(height: 32),

                    // 5. Estadísticas Generales
                    const Text(
                      "Resumen General",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatsGrid(context, authProvider),
                    const SizedBox(height: 32),

                    // 6. Calendario de Actividad
                    const DashboardCalendar(),
                    const SizedBox(height: 24), // Espacio al final del scroll
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir el saludo de bienvenida
  Widget _buildWelcomeHeader(User? user) {
    // Extrae el primer nombre para un saludo más personal
    final firstName = user?.name?.split(' ').first;
    return Text(
      // Si no hay nombre, usa un saludo genérico y amigable
      "Hola, ${firstName != null && firstName.isNotEmpty ? firstName : 'Campeón'} 👋",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Widget para construir la grilla de estadísticas generales
  Widget _buildStatsGrid(BuildContext context, AuthProvider authProvider) {
    // Usamos Wrap para que se adapte a cualquier tamaño de pantalla y evitar overflows.
    return Wrap(
      spacing: 16, // Espacio horizontal entre tarjetas
      runSpacing:
          16, // Espacio vertical si las tarjetas pasan a la siguiente línea
      children: [
        SizedBox(
          // Cada tarjeta ocupará la mitad del ancho de la pantalla, menos los márgenes y el espaciado.
          width: (MediaQuery.of(context).size.width / 2) - (20 + 8),
          height: 100, // Una altura fija para consistencia visual
          child: StatCard(
            icon: Icons.bar_chart_rounded,
            title: "Hábitos Activos",
            value: "${authProvider.activeHabitsCount}",
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width / 2) - (20 + 8),
          height: 100,
          child: StatCard(
            icon: Icons.local_fire_department_rounded,
            title: "Mejor Racha",
            value: "${authProvider.bestStreak} días",
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width / 2) - (20 + 8),
          height: 100,
          child: const StatCard(
            icon: Icons.emoji_events_rounded,
            title: "Logros",
            value: "0/15", // Placeholder
          ),
        ),
        SizedBox(
          width: (MediaQuery.of(context).size.width / 2) - (20 + 8),
          height: 100,
          child: const StatCard(
            icon: Icons.check_circle_rounded,
            title: "Completados",
            value: "76%", // Placeholder
          ),
        ),
      ],
    );
  }
}
