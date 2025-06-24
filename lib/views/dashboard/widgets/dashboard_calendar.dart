// lib/views/dashboard/widgets/dashboard_calendar.dart
import 'package:flutter/material.dart';

class DashboardCalendar extends StatelessWidget {
  const DashboardCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    // Aquí iría la lógica de tu calendario de actividad.
    // Por ahora, un placeholder.
    return Container(
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'Calendario de Actividad (Próximamente)',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }
}
