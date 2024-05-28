import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/views/normal/routinesssss/diet.dart';
import 'package:testapp/views/normal/routinesssss/hydration.dart';
import 'package:testapp/views/normal/routinesssss/workout_routine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CombinedPage extends StatefulWidget {
  @override
  _CombinedPageState createState() => _CombinedPageState();
}

class _CombinedPageState extends State<CombinedPage> {
  DateTime? _selectedDate;
  bool _showCalorieConsumption = false;
  bool _showButtons = false;
  String _username = '';
  int _dailyCalories = 0;
  int _monthlyCalories = 0;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final FireStoreService _fireStoreService = FireStoreService();
    _username = await _fireStoreService.getUserField('username');
    setState(() {});
  }

  Future<void> _fetchDailyCalories() async {
    if (_selectedDate == null || _username.isEmpty) return;

    final doc = await FirebaseFirestore.instance
        .collection('diet_routines')
        .doc('${_selectedDate!.toLocal()}_${_username}')
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        _dailyCalories = data['dailyCalories'] ?? 0;
      });
    } else {
      setState(() {
        _dailyCalories = 0;
      });
    }
  }

  Future<void> _fetchMonthlyCalories() async {
    if (_selectedDate == null || _username.isEmpty) return;

    final monthStart = DateTime(_selectedDate!.year, _selectedDate!.month, 1);
    final monthEnd = DateTime(_selectedDate!.year, _selectedDate!.month + 1, 0);

    final querySnapshot = await FirebaseFirestore.instance
        .collection('diet_routines')
        .where('username', isEqualTo: _username)
        .where('date', isGreaterThanOrEqualTo: monthStart)
        .where('date', isLessThanOrEqualTo: monthEnd)
        .get();

    num monthlyCalories = 0;
    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      monthlyCalories += data['dailyCalories'] ?? 0;
    }

    setState(() {
      _monthlyCalories = monthlyCalories.toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fitness Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              onTap: () {
                _selectDate(context);
              },
              decoration: InputDecoration(
                labelText: 'Select Date',
                hintText: _selectedDate == null
                    ? 'Tap to select date'
                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showCalorieConsumption = true;
                  _showButtons = true;
                  _fetchDailyCalories();
                  _fetchMonthlyCalories();
                });
              },
              child: Text('Confirm Date'),
            ),
            SizedBox(height: 16),
            Visibility(
              visible: _showCalorieConsumption,
              child: Column(
                children: [
                  Text(
                    'Calories consumed for the ${_selectedDate != null ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}' : 'specific day'}: $_dailyCalories',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    'Calories consumed for the ${_selectedDate != null ? '${DateFormat('MMMM yyyy').format(_selectedDate!)}' : 'specific month'}: $_monthlyCalories',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            AnimatedOpacity(
              opacity: _showButtons ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _username.isNotEmpty && _selectedDate != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkoutRoutinePage(
                                  selectedDate: _selectedDate!,
                                  username: _username,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: Text('Workout Routine'),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _username.isNotEmpty && _selectedDate != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DietRoutinePage(
                                  selectedDate: _selectedDate!,
                                  username: _username,
                                ),
                              ),
                            ).then((_) {
                              _fetchDailyCalories();
                              _fetchMonthlyCalories();
                            });
                          }
                        : null,
                    child: Text('Diet Routine'),
                  ),
                  SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _username.isNotEmpty && _selectedDate != null
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HydrationPage(
                                  selectedDate: _selectedDate!,
                                  username: _username,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: Text('Hydration'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchDailyCalories();
      _fetchMonthlyCalories();
    }
  }
}
