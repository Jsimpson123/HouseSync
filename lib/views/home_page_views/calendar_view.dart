import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/event_model.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() {
    return _CalendarView();

  }
}

class _CalendarView extends State<CalendarView> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  //Stores the created calendar events
  Map<DateTime, List<Event>> events = {};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          }
        },
          onFormatChanged: (format) {
    if (_calendarFormat != format) {
    setState(() {
    _calendarFormat = format;
    });
    }
    },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      }
      ),
    );
  }
}
