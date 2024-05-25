import 'package:cloud_firestore/cloud_firestore.dart';

class Exercise {
  final String id; // Ajouter l'ID du document Firestore
  final String name;
  final String description;
  final String videoUrl;
  final int? duration;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.videoUrl,
    this.duration,
  });

  factory Exercise.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Exercise(
      duration: data['duration'],
      id: snapshot.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      videoUrl: data['url'] ?? '',
    );
  }
}

// Modifier votre fonction pour récupérer les exercices
Future<List<Exercise>> getExercices() async {
  try {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('exercices').get();
    List<Exercise> exercises = querySnapshot.docs
        .map((doc) => Exercise.fromDocumentSnapshot(doc))
        .toList();
    return exercises;
  } catch (e) {
    // Handle any potential errors here
    return [];
  }
}

// Ajouter une méthode pour ajouter un exercice à la base de données
Future<void> addExercise(Exercise exercise) async {
  try {
    await FirebaseFirestore.instance.collection('exercices').add({
      'name': exercise.name,
      'description': exercise.description,
      'url': exercise.videoUrl,
    });
  } catch (e) {
    // Handle any potential errors here
  }
}

// Ajouter une méthode pour supprimer un exercice de la base de données
Future<void> deleteExercise(String exerciseId) async {
  try {
    await FirebaseFirestore.instance
        .collection('exercices')
        .doc(exerciseId)
        .delete();
  } catch (e) {
    // Handle any potential errors here
  }
}
