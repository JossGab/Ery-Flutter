import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';

// Importamos los widgets que hemos creado
import 'widgets/stat_card.dart';
import 'widgets/dashboard_calendar.dart';
import 'widgets/habit_progress_section.dart';

// Importamos el sidebar genérico y el provider
import '../../widgets/sidebar_drawer.dart'; // Usamos el sidebar que ya existía
import '../../providers/auth_provider.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // El controlador para el SidebarX
  final _sidebarController = SidebarXController(
    selectedIndex: 1,
    extended: true,
  );

  @override
  void initState() {
    super.initState();
    // Al iniciar la pantalla, le pedimos al AuthProvider que cargue los datos.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;
    // Escuchamos los cambios del AuthProvider para redibujar la UI.
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0E0F1A),
      appBar:
          isMobile
              ? AppBar(
                backgroundColor: const Color(0xFF1B1D2A),
                title: const Text('Ery', style: TextStyle(color: Colors.white)),
                iconTheme: const IconThemeData(color: Colors.white),
              )
              : null,
      // En móvil, el sidebar es un Drawer.
      drawer: isMobile ? SidebarDrawer(controller: _sidebarController) : null,
      body: Row(
        children: [
          // En pantallas grandes, el sidebar está fijo a la izquierda.
          if (!isMobile) SidebarDrawer(controller: _sidebarController),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              // Mostramos un indicador de carga mientras se obtienen los datos.
              child:
                  authProvider.isDashboardLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildMainContent(authProvider),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el contenido principal de la pantalla del dashboard.
  /// Ahora es mucho más corto y legible.
  Widget _buildMainContent(AuthProvider authProvider) {
    // Extraemos los datos del dashboard desde el provider.
    final habitsWithStats =
        authProvider.dashboardData?['habits_con_estadisticas'] as List? ?? [];

    // Calculamos las estadísticas (KPIs).
    final activeHabitsCount = habitsWithStats.length;
    final bestStreak = habitsWithStats.whereType<Map>().fold<int>(0, (
      max,
      habit,
    ) {
      final currentStreak = habit['racha_actual'] ?? 0;
      return currentStreak > max ? currentStreak : max;
    });

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
          // Usamos el widget Wrap para que las tarjetas se ajusten automáticamente.
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              // --- LLAMAMOS A NUESTRO WIDGET REUTILIZABLE ---
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
                value: "0", // Placeholder
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- LLAMAMOS A NUESTROS WIDGETS DE SECCIÓN ---
          _buildSectionContainer(
            title: "Progreso de Hábitos",
            child: const HabitProgressSection(),
          ),
          _buildSectionContainer(
            title: "Calendario de Actividad",
            child: const DashboardCalendar(),
          ),
        ],
      ),
    );
  }

  /// Un widget contenedor genérico para cada sección del dashboard.
  Widget _buildSectionContainer({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(
          0xFF1B1D2A,
        ), // Un color ligeramente diferente para las secciones
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
