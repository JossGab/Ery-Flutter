// lib/views/dashboard/widgets/dashboard_calendar.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../services/api_service.dart';

// El modelo de datos no necesita cambios.
class DailyActivity {
  final int completions;
  final bool hasRelapse;

  DailyActivity({required this.completions, required this.hasRelapse});

  factory DailyActivity.fromJson(Map<String, dynamic> json) {
    return DailyActivity(
      completions: json['completions'] ?? 0,
      hasRelapse: json['hasRelapse'] ?? false,
    );
  }
}

class DashboardCalendar extends StatefulWidget {
  const DashboardCalendar({super.key});

  @override
  State<DashboardCalendar> createState() => _DashboardCalendarState();
}

class _DashboardCalendarState extends State<DashboardCalendar> {
  // --- Estado del Widget ---
  Map<DateTime, DailyActivity> _activityData = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;
  String? _error;

  // --- MEJORA: Se elimina el CalendarFormat para fijarlo en 'mes' ---
  // final CalendarFormat _calendarFormat = CalendarFormat.month;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchActivityData(_focusedDay.year, _focusedDay.month);
  }

  /// Obtiene los datos de actividad para un mes y año específicos desde la API.
  Future<void> _fetchActivityData(int year, int month) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _apiService.getActivityLog(year, month);
      final fetchedData = <DateTime, DailyActivity>{};
      data.forEach((key, value) {
        final date = DateTime.parse(key);
        fetchedData[date] = DailyActivity.fromJson(value);
      });

      if (mounted) {
        setState(() {
          _activityData = fetchedData;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst("Exception: ", "");
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Maneja la selección de un día en el calendario.
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Text(
                '📅 Calendario de Actividad',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: CircularProgressIndicator(color: Colors.white),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    'Error al cargar la actividad:\n$_error',
                    style: GoogleFonts.poppins(
                      color: Colors.redAccent,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                _buildCalendar(),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye y estiliza el widget TableCalendar.
  Widget _buildCalendar() {
    return TableCalendar<DailyActivity>(
      locale: 'es_ES',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,
      // --- MEJORA: Se fija el formato a un mes para evitar el colapso ---
      calendarFormat: CalendarFormat.month,
      availableGestures:
          AvailableGestures.horizontalSwipe, // Solo swipe horizontal
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
        _fetchActivityData(focusedDay.year, focusedDay.month);
      },
      // --- MEJORA: Estilos visuales renovados ---
      headerStyle: HeaderStyle(
        formatButtonVisible:
            false, // Ocultamos el botón de formato (2 weeks, month)
        titleCentered: true,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
        rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: GoogleFonts.poppins(color: Colors.white70),
        defaultTextStyle: GoogleFonts.poppins(color: Colors.white),
        // Estilo para el día de hoy
        todayDecoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blueAccent, width: 1.5),
        ),
        // Estilo para el día seleccionado
        selectedDecoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurpleAccent.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
      // --- MEJORA: Builders para personalizar las celdas de los días ---
      calendarBuilders: CalendarBuilders(
        // Builder para los marcadores (recaídas)
        markerBuilder: (context, date, events) {
          final activity =
              _activityData[DateTime(date.year, date.month, date.day)];
          if (activity != null && activity.hasRelapse) {
            return Positioned(
              right: 5,
              bottom: 5,
              child: _buildRelapseMarker(),
            );
          }
          return null;
        },
        // Builder principal para las celdas de los días
        defaultBuilder: (context, day, focusedDay) {
          final activity =
              _activityData[DateTime(day.year, day.month, day.day)];
          if (activity != null && activity.completions > 0) {
            final color = _getHeatmapColor(activity.completions);
            // --- MEJORA: Usamos AnimatedContainer para una transición suave ---
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.6), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            );
          }
          return null; // Devuelve null para que use el estilo por defecto
        },
      ),
    );
  }

  /// Widget para el marcador de recaída.
  Widget _buildRelapseMarker() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.redAccent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
    );
  }

  /// Devuelve un color basado en la cantidad de hábitos completados (heatmap).
  Color _getHeatmapColor(int completions) {
    if (completions >= 5) return const Color(0xFF00C853); // Verde intenso
    if (completions >= 3) return const Color(0xFF64DD17); // Verde
    if (completions >= 1) return const Color(0xFFAEEA00); // Verde lima
    return Colors.transparent; // No debería ocurrir si completions > 0
  }
}
