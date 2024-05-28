import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DietRoutinePage extends StatefulWidget {
  final DateTime selectedDate;
  final String username;

  DietRoutinePage({required this.selectedDate, required this.username});

  @override
  _DietRoutinePageState createState() => _DietRoutinePageState();
}

class _DietRoutinePageState extends State<DietRoutinePage> {
  final _mealNameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _proteinController = TextEditingController();
  String _mealType = 'Breakfast';

  List<Map<String, dynamic>> _meals = [];
  num _dailyCalories = 0;
  num _monthlyCalories = 0;

  @override
  void initState() {
    super.initState();
    _fetchMeals();
    _fetchMonthlyCalories();
  }

  Future<void> _fetchMeals() async {
    final doc = await FirebaseFirestore.instance
        .collection('diet_routines')
        .doc('${widget.selectedDate.toLocal()}_${widget.username}')
        .get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final meals = data['meals'] as List<dynamic>;
      setState(() {
        _meals = meals.map((e) => Map<String, dynamic>.from(e)).toList();
        _dailyCalories = data['dailyCalories'] ?? 0;
      });
    }
  }

  Future<void> _fetchMonthlyCalories() async {
    final monthStart =
        DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
    final monthEnd =
        DateTime(widget.selectedDate.year, widget.selectedDate.month + 1, 0);

    final querySnapshot = await FirebaseFirestore.instance
        .collection('diet_routines')
        .where('username', isEqualTo: widget.username)
        .where('date', isGreaterThanOrEqualTo: monthStart)
        .where('date', isLessThanOrEqualTo: monthEnd)
        .get();

    num monthlyCalories = 0;
    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      monthlyCalories += data['dailyCalories'] ?? 0;
    }

    setState(() {
      _monthlyCalories = monthlyCalories;
    });
  }

  Future<void> _updateCalories() async {
    final docRef = FirebaseFirestore.instance
        .collection('diet_routines')
        .doc('${widget.selectedDate.toLocal()}_${widget.username}');

    await docRef.set({
      'username': widget.username,
      'date': widget.selectedDate,
      'meals': _meals,
      'dailyCalories': _dailyCalories,
      'monthlyCalories': _monthlyCalories,
    });
  }

  void _addMeal() {
    final meal = {
      'name': _mealNameController.text,
      'type': _mealType,
      'calories': int.parse(_caloriesController.text),
      'carbs': int.parse(_carbsController.text),
      'fat': int.parse(_fatController.text),
      'protein': int.parse(_proteinController.text),
    };
    setState(() {
      _meals.add(meal);
      _dailyCalories += meal['calories'] as num;
      _monthlyCalories += meal['calories'] as num;
    });
    _updateCalories();
    _clearForm();
  }

  void _modifyMeal(int index) {
    final meal = _meals[index];
    _mealNameController.text = meal['name'];
    _mealType = meal['type'];
    _caloriesController.text = meal['calories'].toString();
    _carbsController.text = meal['carbs'].toString();
    _fatController.text = meal['fat'].toString();
    _proteinController.text = meal['protein'].toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Modify Meal'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _mealNameController,
                  decoration: InputDecoration(labelText: 'Meal Name'),
                ),
                DropdownButtonFormField<String>(
                  value: _mealType,
                  items: ['Breakfast', 'Lunch', 'Dinner', 'Other']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _mealType = value!;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Meal Type'),
                ),
                TextFormField(
                  controller: _caloriesController,
                  decoration: InputDecoration(labelText: 'Calories'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _carbsController,
                  decoration: InputDecoration(labelText: 'Carbs'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _fatController,
                  decoration: InputDecoration(labelText: 'Fat'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: _proteinController,
                  decoration: InputDecoration(labelText: 'Protein'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final modifiedMeal = {
                  'name': _mealNameController.text,
                  'type': _mealType,
                  'calories': int.parse(_caloriesController.text),
                  'carbs': int.parse(_carbsController.text),
                  'fat': int.parse(_fatController.text),
                  'protein': int.parse(_proteinController.text),
                };
                setState(() {
                  final oldCalories = _meals[index]['calories'];
                  _meals[index] = modifiedMeal;
                  _dailyCalories = _dailyCalories -
                      (oldCalories as num) +
                      (modifiedMeal['calories'] as num);
                  _monthlyCalories = _monthlyCalories -
                      (oldCalories as num) +
                      (modifiedMeal['calories'] as num);
                });
                _updateCalories();
                Navigator.pop(context);
                _clearForm();
              },
              child: Text('Modify Meal'),
            ),
          ],
        );
      },
    );
  }

  void _deleteMeal(int index) {
    final deletedMealCalories = _meals[index]['calories'];
    setState(() {
      _meals.removeAt(index);
      _dailyCalories -= deletedMealCalories;
      _monthlyCalories -= deletedMealCalories;
    });
    _updateCalories();
  }

  void _clearForm() {
    _mealNameController.clear();
    _caloriesController.clear();
    _carbsController.clear();
    _fatController.clear();
    _proteinController.clear();
    setState(() {
      _mealType = 'Breakfast';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diet Routine'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              child: Column(
                children: [
                  TextFormField(
                    controller: _mealNameController,
                    decoration: InputDecoration(labelText: 'Meal Name'),
                  ),
                  DropdownButtonFormField<String>(
                    value: _mealType,
                    items: ['Breakfast', 'Lunch', 'Dinner', 'Other']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _mealType = value!;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Meal Type'),
                  ),
                  TextFormField(
                    controller: _caloriesController,
                    decoration: InputDecoration(labelText: 'Calories'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _carbsController,
                    decoration: InputDecoration(labelText: 'Carbs'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _fatController,
                    decoration: InputDecoration(labelText: 'Fat'),
                    keyboardType: TextInputType.number,
                  ),
                  TextFormField(
                    controller: _proteinController,
                    decoration: InputDecoration(labelText: 'Protein'),
                    keyboardType: TextInputType.number,
                  ),
                  ElevatedButton(
                    onPressed: _addMeal,
                    child: Text('Add Meal'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _meals.length,
                itemBuilder: (context, index) {
                  final meal = _meals[index];
                  return ListTile(
                    title: Text(
                        '${meal['name']} (${meal['type']}) - ${meal['calories']} kcal'),
                    subtitle: Text(
                        'Carbs: ${meal['carbs']}g, Fat: ${meal['fat']}g, Protein: ${meal['protein']}g'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _modifyMeal(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteMeal(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
