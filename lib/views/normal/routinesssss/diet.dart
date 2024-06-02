import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class DietRoutinePage extends StatefulWidget {
  final DateTime selectedDate;
  final String username;

  const DietRoutinePage({required this.selectedDate, required this.username});

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
  num _dailyCarbs = 0;
  num _dailyFat = 0;
  num _dailyProtein = 0;
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
        _dailyCarbs = data['dailyCarbs'] ?? 0;
        _dailyFat = data['dailyFat'] ?? 0;
        _dailyProtein = data['dailyProtein'] ?? 0;
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

  Future<void> _updateMeals() async {
    final docRef = FirebaseFirestore.instance
        .collection('diet_routines')
        .doc('${widget.selectedDate.toLocal()}_${widget.username}');

    await docRef.set({
      'username': widget.username,
      'date': widget.selectedDate,
      'meals': _meals,
      'dailyCalories': _dailyCalories,
      'dailyCarbs': _dailyCarbs,
      'dailyFat': _dailyFat,
      'dailyProtein': _dailyProtein,
    });

    _fetchMonthlyCalories(); // Recalculate monthly calories after updating meals
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
      _dailyCarbs += meal['carbs'] as num;
      _dailyFat += meal['fat'] as num;
      _dailyProtein += meal['protein'] as num;
      _monthlyCalories += meal['calories'] as num;
    });
    _updateMeals();
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
                  final oldMeal = _meals[index];
                  _dailyCalories -= oldMeal['calories'] as num;
                  _dailyCarbs -= oldMeal['carbs'] as num;
                  _dailyFat -= oldMeal['fat'] as num;
                  _dailyProtein -= oldMeal['protein'] as num;
                  _monthlyCalories -= oldMeal['calories'] as num;

                  _meals[index] = modifiedMeal;
                  _dailyCalories += modifiedMeal['calories'] as num;
                  _dailyCarbs += modifiedMeal['carbs'] as num;
                  _dailyFat += modifiedMeal['fat'] as num;
                  _dailyProtein += modifiedMeal['protein'] as num;
                  _monthlyCalories += modifiedMeal['calories'] as num;
                });
                _updateMeals();
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
    final deletedMeal = _meals[index];
    setState(() {
      _meals.removeAt(index);
      _dailyCalories -= deletedMeal['calories'] as num;
      _dailyCarbs -= deletedMeal['carbs'] as num;
      _dailyFat -= deletedMeal['fat'] as num;
      _dailyProtein -= deletedMeal['protein'] as num;
      _monthlyCalories -= deletedMeal['calories'] as num;
    });
    _updateMeals();
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

  Color _getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diet Routine'),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _dailyCalories > 0 ? 1 : 0,
                            backgroundColor: Colors.grey[200],
                            color: _getRandomColor(),
                            strokeWidth: 12,
                          ),
                          Text(
                            '$_dailyCalories',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text('Calories')
                    ],
                  ),
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _dailyCarbs > 0 ? 1 : 0,
                            backgroundColor: Colors.grey[200],
                            color: _getRandomColor(),
                            strokeWidth: 12,
                          ),
                          Text(
                            '$_dailyCarbs',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text('Carbs')
                    ],
                  ),
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _dailyFat > 0 ? 1 : 0,
                            backgroundColor: Colors.grey[200],
                            color: _getRandomColor(),
                            strokeWidth: 12,
                          ),
                          Text(
                            '$_dailyFat',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text('Fat')
                    ],
                  ),
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: _dailyProtein > 0 ? 1 : 0,
                            backgroundColor: Colors.grey[200],
                            color: _getRandomColor(),
                            strokeWidth: 12,
                          ),
                          Text(
                            '$_dailyProtein',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text('Protein')
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
              SizedBox(height: 20),
              Text(
                'Monthly Calories: $_monthlyCalories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
