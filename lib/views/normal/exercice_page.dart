import 'package:flutter/material.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<String> _exercises = [];

  Widget _buildItem(String exercise, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
        title: Text(exercise),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            final int index = _exercises.indexOf(exercise);
            setState(() {
              _exercises.removeAt(index);
            });
            _listKey.currentState!.removeItem(
              index,
              (context, animation) => _buildItem(exercise, animation),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercices'),
      ),
      body: AnimatedList(
        key: _listKey,
        initialItemCount: _exercises.length,
        itemBuilder: (context, index, animation) {
          return _buildItem(_exercises[index], animation);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ici, vous pouvez demander à l'utilisateur d'entrer un nouvel exercice
          // et appeler _addExercise avec le nouvel exercice.
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
