import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/api_service.dart';

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
  Map<DateTime, DailyActivity> _activityData = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;
  String? _error;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchActivityData(_focusedDay.year, _focusedDay.month);
  }

  Future<void> _fetchActivityData(int year, int month) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _apiService.getActivityLog(year, month);
      final fetched = <DateTime, DailyActivity>{};
      data.forEach((key, value) {
        final date = DateTime.parse(key);
        fetched[date] = DailyActivity.fromJson(value);
      });

      setState(() => _activityData = fetched);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst("Exception: ", ""));
    } finally {
      setState(() => _isLoading = false);
    }
  }

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
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withOpacity(0.06),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 16),
          if (_isLoading)
            const CircularProgressIndicator(color: Colors.white)
          else if (_error != null)
            Text(
              'Error: $_error',
              style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            )
          else
            SizedBox(height: 420, child: _buildCalendar()),
        ],
      ),
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
      onFormatChanged: (format) => setState(() => _calendarFormat = format),
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
        _fetchActivityData(focusedDay.year, focusedDay.month);
      },
      sixWeekMonthsEnforced: true,
      rowHeight: 52,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: GoogleFonts.poppins(color: const Color(0xFF9ca3af)),
        todayDecoration: const BoxDecoration(
          color: Color(0xFF374151),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: Color(0xFF6366F1),
          shape: BoxShape.circle,
        ),
        defaultTextStyle: GoogleFonts.poppins(color: Colors.white),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.white),
        rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.white),
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isNotEmpty && events.first.hasRelapse) {
            return Positioned(
              right: 4,
              bottom: 4,
              child: _buildMarker(Colors.redAccent),
            );
          }
          return null;
        },
        defaultBuilder: (context, day, _) {
          final activity =
              _activityData[DateTime(day.year, day.month, day.day)];
          if (activity != null && activity.completions > 0) {
            final color = _getHeatmapColor(activity.completions);
            return Center(
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.6),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${day.day}',
                    style: GoogleFonts.poppins(color: Colors.white),
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
      width: 10,
      height: 10,
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
