import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  final TextEditingController _goalController = TextEditingController();

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

  void _addIntake(int amount) {
    setState(() {
      _currentIntake += amount;
    });
    _saveHydrationData();

    _showGoalReachedToast();
  }

  void _setGoal(int goal) {
    setState(() {
      _goal = goal;
    });
    _saveHydrationData();
  }

  void _showGoalReachedToast() {
    if (_currentIntake >= _goal) {
      Fluttertoast.showToast(
        msg: "Congratulations! You've reached your hydration goal!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  void dispose() {
    _intakeController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (_currentIntake / _goal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hydration Tracker'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              _buildProgressIndicator(percentage),
              SizedBox(height: 20),
              _buildIntakeControls(),
              SizedBox(height: 20),
              _buildGoalInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Hydration Goal: $_goal ml',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          'Current Intake: $_currentIntake ml',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(double percentage) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: percentage,
          strokeWidth: 10,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_drink,
              size: 50,
              color: Colors.blue,
            ),
            SizedBox(height: 10),
            Text(
              '${(_currentIntake / _goal * 100).toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIntakeControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextField(
          controller: _intakeController,
          decoration: InputDecoration(
            labelText: 'Enter intake (ml)',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.local_drink),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            final intake = int.tryParse(_intakeController.text) ?? 0;
            _addIntake(intake);
            _intakeController.clear();
          },
          child: Text('Add Intake'),
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
        ),
        SizedBox(height: 16),
        _buildQuickAddChips(),
      ],
    );
  }

  Widget _buildQuickAddChips() {
    return Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildQuickAddChip('100ml', 100),
        _buildQuickAddChip('200ml', 200),
        _buildQuickAddChip('250ml', 250),
        _buildQuickAddChip('300ml', 300),
      ],
    );
  }

  Widget _buildQuickAddChip(String label, int amount) {
    return ChoiceChip(
      label: Text(label),
      selected: false,
      onSelected: (bool selected) {
        if (selected) _addIntake(amount);
      },
      avatar: Icon(Icons.local_drink),
    );
  }

  Widget _buildGoalInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextField(
          controller: _goalController,
          decoration: InputDecoration(
            labelText: 'Set new goal (ml)',
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.flag),
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            final goal = int.tryParse(_goalController.text) ?? 2000;
            _setGoal(goal);
            _goalController.clear();
          },
          child: Text('Set Goal'),
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
        ),
      ],
    );
  }
}
