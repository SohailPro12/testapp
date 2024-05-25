import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:testapp/views/normal/vedeolistescrean.dart';
import 'package:percent_indicator/percent_indicator.dart';

class CombinedPage extends StatefulWidget {
  @override
  _CombinedPageState createState() => _CombinedPageState();
}

class _CombinedPageState extends State<CombinedPage> {
  final PageController _pageController = PageController();
  final GlobalKey<MealEntryPageState> _mealEntryPageKey =
      GlobalKey<MealEntryPageState>();
  final GlobalKey<_HydrationTrackerState> _hydrationTrackerKey =
      GlobalKey<_HydrationTrackerState>(); // Correction de la clé ici

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              children: [
                CalendarPage(),
                MealEntryPage(
                  key: _mealEntryPageKey,
                  isUserLoggedIn: false,
                ),
                HydrationTracker(
                  key: _hydrationTrackerKey,
                  initialCurrentHydration: 0.0,
                  initialHydrationGoal:
                      0.0, // Utilisation de la clé correcte ici
                ),
              ],
            ),
          ),
          SmoothPageIndicator(
            controller: _pageController,
            count:
                3, // Mettre à jour le compteur à 3 pour inclure la page d'hydratation
            effect: WormEffect(
              dotWidth: 10.0,
              dotHeight: 10.0,
              activeDotColor: Colors.blue,
            ),
          ),
          SizedBox(
              height: 16), // Optionnel : ajoute une marge sous l'indicateur
        ],
      ),
    );
  }
}

class HydrationTracker extends StatefulWidget {
  final double initialCurrentHydration;
  final double initialHydrationGoal;

  HydrationTracker({
    Key? key,
    required this.initialCurrentHydration,
    required this.initialHydrationGoal,
  }) : super(key: key);

  @override
  _HydrationTrackerState createState() => _HydrationTrackerState();
}

class _HydrationTrackerState extends State<HydrationTracker> {
  late double currentHydration;
  late double hydrationGoal;
  final TextEditingController _goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentHydration = widget.initialCurrentHydration;
    hydrationGoal = widget.initialHydrationGoal;
    _goalController.text = hydrationGoal.toString();
    _updateHydrationGoal(); // Update hydration goal
    _loadHydrationData(); // Load data from Firestore on initialization
  }

  Future<void> _loadHydrationData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('hydration')
          .doc('user_hydration') // Assuming a single document for the user
          .get();
      if (doc.exists) {
        setState(() {
          currentHydration = doc['currentHydration'];
          hydrationGoal = doc['hydrationGoal'];
          _goalController.text = hydrationGoal.toString();
        });
      }
    } catch (e) {
      print('Error loading hydration data: $e');
    }
  }

  Future<void> _saveHydrationData() async {
    try {
      await FirebaseFirestore.instance
          .collection('hydration')
          .doc('user_hydration')
          .set({
        'currentHydration': currentHydration,
        'hydrationGoal': hydrationGoal,
      });
    } catch (e) {
      print('Error saving hydration data: $e');
    }
  }

  void _updateHydrationGoal() {
    setState(() {
      hydrationGoal = double.tryParse(_goalController.text) ?? hydrationGoal;
    });
    _saveHydrationData(); // Save data after updating
  }

  void _resetHydration() {
    setState(() {
      currentHydration = widget.initialCurrentHydration;
      hydrationGoal = widget.initialHydrationGoal;
      _goalController.text = hydrationGoal.toString();
    });
    _saveHydrationData(); // Save data after updating
    _deleteHydrationData(); // Delete data from Firestore
  }

  Future<void> _deleteHydrationData() async {
    try {
      await FirebaseFirestore.instance
          .collection('hydration')
          .doc('user_hydration')
          .delete();
    } catch (e) {
      print('Error deleting hydration data: $e');
    }
  }

  void _addHydration(double amount) {
    setState(() {
      currentHydration += amount;
      if (currentHydration > hydrationGoal) {
        currentHydration = hydrationGoal;
      }
    });
    _saveHydrationData(); // Save data after updating
  }

  Widget _buildHydrationButton(double amount, IconData icon) {
    return ElevatedButton(
      onPressed: () {
        _addHydration(amount);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          SizedBox(width: 8),
          Text('$amount ml'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double hydrationPercentage =
        (hydrationGoal > 0) ? (currentHydration / hydrationGoal) * 100 : 0;

    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Hydration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: (hydrationGoal > 0)
                        ? currentHydration / hydrationGoal
                        : 0,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${hydrationPercentage.toStringAsFixed(0)}%',
                      style:
                          TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${currentHydration.toStringAsFixed(0)} ml',
                      style: TextStyle(fontSize: 24),
                    ),
                    Text(
                      '-${(hydrationGoal - currentHydration).toStringAsFixed(0)} ml',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _goalController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Set Hydration Goal (ml)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _updateHydrationGoal(),
            ),
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildHydrationButton(250, Icons.local_drink),
                _buildHydrationButton(500, Icons.local_drink_outlined),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildHydrationButton(180, Icons.coffee),
                _buildHydrationButton(250, Icons.local_bar),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetHydration,
              child: Text('Reset Hydration'),
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, Map<String, dynamic>> _watchStats = {};

  TextEditingController _noteController =
      TextEditingController(); // Adding text controller for note input

  @override
  void initState() {
    super.initState();
    _fetchWatchStats();
  }

  Future<void> _fetchWatchStats() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('watch_stats').get();

    Map<DateTime, Map<String, dynamic>> stats = {};
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      DateTime date = DateFormat('yyyy-MM-dd').parse(doc.id);
      stats[date] = {
        'video_count': data['video_count'] ?? 0,
        'total_time': data['total_time'] ?? 0,
        'note': data['note'] ?? '', // Adding note field
      };
    }

    setState(() {
      _watchStats = stats;
    });
  }

  Future<void> _saveNote() async {
    if (_selectedDay == null) {
      // Check if a day is selected
      return;
    }

    // Extract the selected date
    DateTime dateOnly =
        DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    String formattedDate = DateFormat('yyyy-MM-dd').format(dateOnly);

    try {
      // Save the note to Firestore
      await FirebaseFirestore.instance
          .collection('watch_stats')
          .doc(formattedDate)
          .set({'note': _noteController.text}, SetOptions(merge: true));

      // Refresh the data after saving
      await _fetchWatchStats();

      // Clear input after saving
      _noteController.clear();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Note saved successfully for $formattedDate')),
      );
    } catch (e) {
      // Handle errors
      print('Error saving note: $e');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving note')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar with Video Stats'),
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
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                // Remove the time part of the date for comparison
                DateTime dateOnly = DateTime(date.year, date.month, date.day);
                if (_watchStats[dateOnly] != null) {
                  String note =
                      _watchStats[dateOnly]!['note'] ?? ''; // Fetching note
                  if (note.isNotEmpty) {
                    return Text(note); // Adding note as a marker
                  }
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Enter a note',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_selectedDay != null) {
                await _saveNote();
                _noteController.clear(); // Clear input after saving
              }
            },
            child: Text('Save Note'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoListScreen(),
                ),
              );
            },
            child: Text('Add Exercises'),
          ),
        ],
      ),
    );
  }
}

class MealEntryPage extends StatefulWidget {
  final bool isUserLoggedIn;

  MealEntryPage({Key? key, required this.isUserLoggedIn}) : super(key: key);

  @override
  MealEntryPageState createState() => MealEntryPageState();
}

class MealEntryPageState extends State<MealEntryPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mealController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final List<Map<String, dynamic>> _entries = [];
  int _totalCalories = 0;
  int _totalProtein = 0;
  int _totalCarbs = 0;
  int _totalFat = 0;

  final int _caloriesGoal = 400000000;
  final int _proteinGoal = 4000000000;
  final int _carbsGoal = 400000000;
  final int _fatGoal = 400000000;

  DateTime _startOfWeek = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startOfWeek = _getStartOfWeek(DateTime.now());
    _loadMeals();
  }

  DateTime _getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _resetTotals() {
    _totalCalories = 0;
    _totalProtein = 0;
    _totalCarbs = 0;
    _totalFat = 0;
    _entries.clear();
  }

  void _loadMeals() async {
    Timestamp startOfWeekTimestamp = Timestamp.fromDate(
        _startOfWeek.subtract(Duration(days: _startOfWeek.weekday - 1)));
    Timestamp endOfWeekTimestamp = Timestamp.fromDate(
        _startOfWeek.add(Duration(days: 7 - _startOfWeek.weekday)));

    FirebaseFirestore.instance
        .collection('meals')
        .where('date', isGreaterThanOrEqualTo: startOfWeekTimestamp)
        .where('date', isLessThan: endOfWeekTimestamp)
        .get()
        .then((QuerySnapshot querySnapshot) {
      setState(() {
        _entries
            .clear(); // Effacez les anciennes données avant de charger les nouvelles
        _resetTotals();
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> meal = doc.data() as Map<String, dynamic>;
          meal['date'] = meal['date'] as Timestamp;
          _entries.add(meal);
          _totalCalories += meal['calories'] as int;
          _totalProtein += meal['protein'] as int;
          _totalCarbs += meal['carbs'] as int;
          _totalFat += meal['fat'] as int;
        }
      });
    });
  }

  List<Map<String, dynamic>> _getEntriesForCurrentWeek() {
    return _entries.where((entry) {
      Timestamp entryDate =
          entry['date'] as Timestamp; // Traiter la date comme Timestamp
      return entryDate
              .toDate()
              .isAfter(_startOfWeek.subtract(Duration(days: 1))) &&
          entryDate.toDate().isBefore(_startOfWeek.add(Duration(days: 7)));
    }).toList();
  }

  void _addEntry() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        DateTime now = DateTime.now();
        if (_getStartOfWeek(now) != _startOfWeek) {
          _startOfWeek = _getStartOfWeek(now);
          _resetTotals();
        }

        int calories = int.parse(_caloriesController.text);
        int protein = int.parse(_proteinController.text);
        int carbs = int.parse(_carbsController.text);
        int fat = int.parse(_fatController.text);

        Map<String, dynamic> meal = {
          'meal': _mealController.text,
          'calories': calories,
          'protein': protein,
          'carbs': carbs,
          'fat': fat,
          'date': Timestamp.fromDate(now), // Convertir DateTime en Timestamp
        };

        _entries.add(meal);
        _totalCalories += calories;
        _totalProtein += protein;
        _totalCarbs += carbs;
        _totalFat += fat;

        FirebaseFirestore.instance.collection('meals').add(meal);

        _mealController.clear();
        _caloriesController.clear();
        _proteinController.clear();
        _carbsController.clear();
        _fatController.clear();
      });
    }
  }

  void _removeEntry(int index) async {
    Map<String, dynamic> entryToRemove =
        this._entries[index]; // Accédez à la liste globale de repas

    QuerySnapshot mealsQuery = await FirebaseFirestore.instance
        .collection('meals')
        .where('meal', isEqualTo: entryToRemove['meal'])
        .where('calories', isEqualTo: entryToRemove['calories'])
        .where('protein', isEqualTo: entryToRemove['protein'])
        .where('carbs', isEqualTo: entryToRemove['carbs'])
        .where('fat', isEqualTo: entryToRemove['fat'])
        .where('date', isEqualTo: entryToRemove['date'])
        .get();

    for (var doc in mealsQuery.docs) {
      await doc.reference.delete();
    }

    setState(() {
      int calories = entryToRemove['calories'];
      int protein = entryToRemove['protein'];
      int carbs = entryToRemove['carbs'];
      int fat = entryToRemove['fat'];

      _totalCalories -= calories;
      _totalProtein -= protein;
      _totalCarbs -= carbs;
      _totalFat -= fat;

      this._entries.removeAt(index); // Supprimez le repas de la liste globale
    });
  }

  void _editEntry(int index) {
    setState(() {
      _mealController.text = _entries[index]['meal'];
      _caloriesController.text = _entries[index]['calories'].toString();
      _proteinController.text = _entries[index]['protein'].toString();
      _carbsController.text = _entries[index]['carbs'].toString();
      _fatController.text = _entries[index]['fat'].toString();

      _removeEntry(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> currentWeekEntries = _getEntriesForCurrentWeek();

    return Scaffold(
        appBar: AppBar(
          title: Text('Meal Tracker'),
        ),
        body: Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
                child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: CircularPercentIndicator(
                            radius: 80.0,
                            lineWidth: 10.0,
                            percent: min(_totalCalories / _caloriesGoal, 1.0),
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${_totalCalories}kcal',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Eaten',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                            progressColor: Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: CircularPercentIndicator(
                            radius: 80.0,
                            lineWidth: 10.0,
                            percent: min(_totalProtein / _proteinGoal, 1.0),
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${_totalProtein}g',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Protein',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                            progressColor: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: CircularPercentIndicator(
                            radius: 80.0,
                            lineWidth: 10.0,
                            percent: min(_totalCarbs / _carbsGoal, 1.0),
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${_totalCarbs}g',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Carbs',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                            progressColor: Colors.orange,
                          ),
                        ),
                        Expanded(
                          child: CircularPercentIndicator(
                            radius: 80.0,
                            lineWidth: 10.0,
                            percent: min(_totalFat / _fatGoal, 1.0),
                            center: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${_totalFat}g',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Fat',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                            progressColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _mealController,
                            decoration: InputDecoration(labelText: 'Meal'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter a meal';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _caloriesController,
                            decoration: InputDecoration(labelText: 'Calories'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter calories';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _proteinController,
                            decoration:
                                InputDecoration(labelText: 'Protein (g)'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter protein';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _carbsController,
                            decoration: InputDecoration(labelText: 'Carbs (g)'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter carbs';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            controller: _fatController,
                            decoration: InputDecoration(labelText: 'Fat (g)'),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter fat';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _addEntry,
                            child: Text('Add Entry'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: currentWeekEntries.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(currentWeekEntries[index]['meal']),
                          subtitle: Text(
                              '${currentWeekEntries[index]['calories']} kcal, ${currentWeekEntries[index]['protein']}g protein, ${currentWeekEntries[index]['carbs']}g carbs, ${currentWeekEntries[index]['fat']}g fat'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editEntry(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _removeEntry(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ]))));
  }
}
