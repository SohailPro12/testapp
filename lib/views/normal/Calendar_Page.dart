import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:testapp/views/normal/exercice_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier de routines'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          if (_selectedDay != null)
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text('Déjeuner'),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Entrez votre déjeuner ici',
                      ),
                    ),
                    Text('lunch'),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Entrez votre lunch ici',
                      ),
                    ),
                    Text('diner'),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Entrez votre diner ici',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExercisePage()),
              );
            },
            child: const Text('Ajouter des exercices'),
          )
        ],
      ),
    );
  }
}
