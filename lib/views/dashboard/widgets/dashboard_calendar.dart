import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../providers/auth_provider.dart';

/// Widget que encapsula toda la lógica y la UI del calendario del dashboard.
class DashboardCalendar extends StatefulWidget {
  const DashboardCalendar({super.key});

  @override
  State<DashboardCalendar> createState() => _DashboardCalendarState();
}

class _DashboardCalendarState extends State<DashboardCalendar> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // Escuchamos al AuthProvider para obtener los datos del calendario.
    final authProvider = Provider.of<AuthProvider>(context);
    final activityLog = authProvider.activityLog ?? {};

    // Convertimos los datos de la API al formato que espera el calendario.
    final events = <DateTime, List<Map<String, dynamic>>>{};
    activityLog.forEach((dateString, data) {
      try {
        if (data is Map<String, dynamic>) {
          final date = DateTime.parse(dateString);
          final utcDate = DateTime.utc(date.year, date.month, date.day);
          events[utcDate] = [data];
        }
      } catch (e) {
        debugPrint(
          "Error parseando fecha del calendario: $dateString, data: $data, error: $e",
        );
      }
    });

    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.month,
      locale: 'es_ES',

      // Se llama cuando el usuario cambia de mes.
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
        // Pedimos al provider que cargue los datos del nuevo mes.
        authProvider.fetchActivityLogForMonth(
          focusedDay.year,
          focusedDay.month,
        );
      },

      // Carga los eventos para un día específico.
      eventLoader: (day) {
        final utcDay = DateTime.utc(day.year, day.month, day.day);
        return events[utcDay] ?? [];
      },

      // Construye los marcadores visuales para los eventos.
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isEmpty) return null;

          if (events.first is! Map<String, dynamic>) return null;
          final eventData = events.first as Map<String, dynamic>;

          final hasRelapse = eventData['hasRelapse'] as bool? ?? false;
          final completions = eventData['completions'] as int? ?? 0;

          Color markerColor = Colors.transparent;
          if (hasRelapse) {
            markerColor = Colors.redAccent.withOpacity(0.7);
          } else if (completions > 0) {
            markerColor =
                Color.lerp(
                  Colors.green.shade300,
                  Colors.green.shade900,
                  (completions / 5.0).clamp(0.0, 1.0),
                ) ??
                Colors.green;
          }

          if (markerColor == Colors.transparent) return null;

          return Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: markerColor,
              shape: BoxShape.circle,
            ),
          );
        },
      ),

      // Estilos visuales del calendario.
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Color(0x556366F1),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Color(0xFF6366F1),
          shape: BoxShape.circle,
        ),
        defaultTextStyle: TextStyle(color: Colors.white70),
        weekendTextStyle: TextStyle(color: Colors.white54),
        outsideTextStyle: TextStyle(color: Colors.white24),
      ),
      headerStyle: const HeaderStyle(
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
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
