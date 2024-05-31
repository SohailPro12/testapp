import 'package:cloud_firestore/cloud_firestore.dart';

class Meal {
  final String? id;
  final String userId;
  final String name;
  final int calories;
  final int carbs;
  final int protein;
  final int fat;
  final DateTime date;

  Meal({
    this.id,
    required this.userId,
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'calories': calories,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
      'date': date,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      calories: map['calories'],
      carbs: map['carbs'],
      protein: map['protein'],
      fat: map['fat'],
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}

class Hydration {
  final double currentHydration;
  final double hydrationGoal;
  final DateTime date;

  Hydration({
    required this.currentHydration,
    required this.hydrationGoal,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'currentHydration': currentHydration,
      'hydrationGoal': hydrationGoal,
      'date': date,
    };
  }

  factory Hydration.fromMap(Map<String, dynamic> map) {
    return Hydration(
      currentHydration: map['currentHydration'],
      hydrationGoal: map['hydrationGoal'],
      date: (map['date'] as Timestamp).toDate(),
    );
  }
}

class Exercise {
  final String id;
  final String title;
  final String description;
  final String videoUrl;

  Exercise({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
    };
  }

  static Exercise fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      videoUrl: map['videoUrl'],
    );
  }
}

class UserExercise {
  final String userId;
  final String title;
  final String description;
  final String videoUrl;

  UserExercise({
    required this.userId,
    required this.title,
    required this.description,
    required this.videoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
    };
  }

  static UserExercise fromMap(Map<String, dynamic> map) {
    return UserExercise(
      userId: map['userId'],
      title: map['title'],
      description: map['description'],
      videoUrl: map['videoUrl'],
    );
  }
}
