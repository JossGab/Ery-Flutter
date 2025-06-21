// dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:sidebarx/sidebarx.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _controller = SidebarXController(selectedIndex: 1);
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
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
      drawer:
          isMobile
              ? Drawer(
                child: SidebarX(
                  controller: _controller,
                  theme: SidebarXTheme(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B1D2A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    hoverColor: Colors.blue.withOpacity(0.1),
                    textStyle: const TextStyle(color: Colors.white),
                    selectedTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    selectedItemDecoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    iconTheme: const IconThemeData(color: Colors.white54),
                    selectedIconTheme: const IconThemeData(color: Colors.white),
                  ),
                  items: [
                    SidebarXItem(icon: Icons.home_rounded, label: 'Inicio'),
                    SidebarXItem(
                      icon: Icons.dashboard_rounded,
                      label: 'Mi Dashboard',
                    ),
                    SidebarXItem(
                      icon: Icons.person_rounded,
                      label: 'Mi Perfil',
                    ),
                    SidebarXItem(
                      icon: Icons.edit_note_rounded,
                      label: 'Mis Hábitos',
                    ),
                  ],
                  footerItems: [
                    SidebarXItem(
                      icon: Icons.logout_rounded,
                      label: 'Cerrar Sesión',
                      onTap:
                          () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                    ),
                  ],
                ),
              )
              : null,
      body: Row(
        children: [
          if (!isMobile)
            SidebarX(
              controller: _controller,
              theme: SidebarXTheme(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1D2A),
                  borderRadius: BorderRadius.circular(16),
                ),
                hoverColor: Colors.blue.withOpacity(0.1),
                textStyle: const TextStyle(color: Colors.white),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                selectedItemDecoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                iconTheme: const IconThemeData(color: Colors.white54),
                selectedIconTheme: const IconThemeData(color: Colors.white),
              ),
              items: [
                SidebarXItem(icon: Icons.home_rounded, label: 'Inicio'),
                SidebarXItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Mi Dashboard',
                ),
                SidebarXItem(icon: Icons.person_rounded, label: 'Mi Perfil'),
                SidebarXItem(
                  icon: Icons.edit_note_rounded,
                  label: 'Mis Hábitos',
                ),
              ],
              footerItems: [
                SidebarXItem(
                  icon: Icons.logout_rounded,
                  label: 'Cerrar Sesión',
                  onTap:
                      () => Navigator.pushReplacementNamed(context, '/login'),
                ),
              ],
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildMainContent(isMobile),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isMobile) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = isMobile ? double.infinity : (screenWidth - 100) / 3;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mi Dashboard",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatCard(
                Icons.bar_chart,
                "Hábitos Activos",
                "0",
                cardWidth,
              ),
              _buildStatCard(
                Icons.bolt,
                "Mejor Racha Actual",
                "0 días",
                cardWidth,
              ),
              _buildStatCard(Icons.emoji_events, "Logros", "0", cardWidth),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              _buildBox(
                "Progreso de Hábitos",
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "¡Es hora de empezar!\nAún no tienes hábitos para seguir.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Crea tu primer hábito",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildBox(
                "Actividad Reciente",
                const Text(
                  "Aún no hay actividad reciente.",
                  style: TextStyle(color: Colors.white60),
                ),
              ),
              const SizedBox(height: 16),
              _buildBox("Calendario", _buildCalendar()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String title,
    String value,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF23263A),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox(String title, Widget child) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF23263A),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Color(0xFF6366F1),
          shape: BoxShape.circle,
        ),
        defaultTextStyle: TextStyle(color: Colors.white70),
        weekendTextStyle: TextStyle(color: Colors.white60),
      ),
      headerStyle: const HeaderStyle(
        titleTextStyle: TextStyle(color: Colors.white),
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: Colors.white60),
        weekendStyle: TextStyle(color: Colors.white54),
      ),
    );
  }
}
