import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HydrationPage extends StatefulWidget {
  final DateTime selectedDate;
  final String username;

  HydrationPage({required this.selectedDate, required this.username});

  @override
  _HydrationPageState createState() => _HydrationPageState();
}

class _HydrationPageState extends State<HydrationPage> {
  int _goal = 2000; // Default goal in ml
  int _currentIntake = 0;
  final TextEditingController _intakeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHydrationData();
  }

  Future<void> _fetchHydrationData() async {
    final doc = await FirebaseFirestore.instance
        .collection('hydration')
        .doc('${widget.selectedDate.toLocal()}_${widget.username}')
        .get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        _goal = data['goal'] ?? 2000;
        _currentIntake = data['currentIntake'] ?? 0;
      });
    }
  }

  Future<void> _saveHydrationData() async {
    await FirebaseFirestore.instance
        .collection('hydration')
        .doc('${widget.selectedDate.toLocal()}_${widget.username}')
        .set({
      'username': widget.username,
      'date': widget.selectedDate,
      'goal': _goal,
      'currentIntake': _currentIntake,
    });
  }

  void _addIntake() {
    final intake = int.tryParse(_intakeController.text) ?? 0;
    setState(() {
      _currentIntake += intake;
    });
    _intakeController.clear();
    _saveHydrationData();
  }

  @override
  void dispose() {
    _intakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (_currentIntake / _goal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hydration Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Hydration Goal: $_goal ml',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Current Intake: $_currentIntake ml',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(
              value: percentage,
              strokeWidth: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _intakeController,
              decoration: InputDecoration(labelText: 'Add water intake (ml)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addIntake,
              child: Text('Add Intake'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final newGoal = await _showGoalDialog();
                if (newGoal != null) {
                  setState(() {
                    _goal = newGoal;
                  });
                  _saveHydrationData();
                }
              },
              child: Text('Set New Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Future<int?> _showGoalDialog() {
    final TextEditingController goalController = TextEditingController();

    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Set Hydration Goal'),
          content: TextFormField(
            controller: goalController,
            decoration: InputDecoration(labelText: 'Goal (ml)'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final goal = int.tryParse(goalController.text);
                Navigator.of(context).pop(goal);
              },
              child: Text('Set Goal'),
            ),
          ],
        );
      },
    );
  }
}
