/*
================================================================================
 ARCHIVO: lib/views/dashboard/widgets/dashboard_calendar.dart
 INSTRUCCIONES: Reemplaza el contenido de este archivo.
 Esta versión utiliza el ApiService centralizado en lugar de http.get
================================================================================
*/
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:developer' as developer;

// Ajusta la ruta de importación según tu estructura
import '../../../services/api_service.dart';

// (El modelo DailyActivity no cambia)
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
  // Se mantiene el mismo estado del widget
  late final ValueNotifier<List<DailyActivity>> _selectedEvents;
  Map<DateTime, DailyActivity> _activityData = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;
  String? _error;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Instancia del ApiService
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _fetchActivityData(_focusedDay.year, _focusedDay.month);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  // --- LÓGICA DE CONEXIÓN AHORA USANDO ApiService ---
  Future<void> _fetchActivityData(int year, int month) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Llamamos al método centralizado de nuestro servicio
      final Map<String, dynamic> data = await _apiService.getActivityLog(
        year,
        month,
      );

      final Map<DateTime, DailyActivity> fetchedActivities = {};
      data.forEach((dateString, activityJson) {
        final date = DateTime.parse(dateString);
        fetchedActivities[date] = DailyActivity.fromJson(activityJson);
      });

      if (mounted) {
        setState(() {
          _activityData = fetchedActivities;
        });
      }
    } catch (e) {
      developer.log(
        'Error capturado por el widget del calendario',
        name: 'EryApp.CalendarWidget',
        error: e,
      );
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
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

  // (El resto del widget no tiene cambios, se mantiene igual que antes)

  List<DailyActivity> _getEventsForDay(DateTime day) {
    final activity = _activityData[DateTime(day.year, day.month, day.day)];
    return activity != null ? [activity] : [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1f2937),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            _buildCalendar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            'Calendario de Actividad',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return TableCalendar<DailyActivity>(
      locale: 'es_ES',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,
      calendarFormat: _calendarFormat,
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
        _fetchActivityData(focusedDay.year, focusedDay.month);
      },
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: TextStyle(color: Color(0xFF9ca3af)),
        todayDecoration: BoxDecoration(
          color: Color(0xFF374151),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Color(0xFF4f46e5),
          shape: BoxShape.circle,
        ),
        defaultTextStyle: TextStyle(color: Colors.white),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 16),
        leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
        rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isNotEmpty && events.first.hasRelapse) {
            return Positioned(
              right: 1,
              bottom: 1,
              child: _buildMarker(Colors.red),
            );
          }
          return null;
        },
        defaultBuilder: (context, day, focusedDay) {
          final activity =
              _activityData[DateTime(day.year, day.month, day.day)];
          if (activity != null && activity.completions > 0) {
            Color bgColor = _getHeatmapColor(activity.completions);
            return Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMarker(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Color _getHeatmapColor(int completions) {
    if (completions >= 5) return Colors.green.shade800;
    if (completions >= 3) return Colors.green.shade600;
    if (completions >= 1) return Colors.green.shade400;
    return Colors.transparent;
  }
}
