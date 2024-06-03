import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart';

class WorkoutRoutinePage extends StatefulWidget {
  final DateTime selectedDate;
  final String username;

  WorkoutRoutinePage({required this.selectedDate, required this.username});

  @override
  _WorkoutRoutinePageState createState() => _WorkoutRoutinePageState();
}

class _WorkoutRoutinePageState extends State<WorkoutRoutinePage> {
  List<Map<String, dynamic>> _selectedExercises = [];

  @override
  void initState() {
    super.initState();
    _fetchSelectedExercises();
  }

  Future<void> _fetchSelectedExercises() async {
    final doc = await FirebaseFirestore.instance
        .collection('selected_exercises')
        .doc('${widget.selectedDate.toLocal()}_${widget.username}')
        .get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      final exercises = data['exercises'] as List<dynamic>;
      setState(() {
        _selectedExercises =
            exercises.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  Future<void> _saveExercises() async {
    await FirebaseFirestore.instance
        .collection('selected_exercises')
        .doc('${widget.selectedDate.toLocal()}_${widget.username}')
        .set({
      'username': widget.username,
      'date': widget.selectedDate,
      'exercises': _selectedExercises,
    });
  }

  void _navigateToPredefinedExercises() async {
    final selected = await Navigator.push<List<Map<String, dynamic>>>(
      context,
      MaterialPageRoute(
        builder: (context) => PredefinedExercisesPage(),
      ),
    );
    if (selected != null) {
      setState(() {
        _selectedExercises.addAll(selected);
      });
      _saveExercises();
    }
  }

  void _navigateToAddCustomExercise() async {
    final customExercise = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddCustomExercisePage(
          selectedDate: widget.selectedDate,
          username: widget.username,
        ),
      ),
    );
    if (customExercise != null) {
      setState(() {
        _selectedExercises.add(customExercise);
      });
      _saveExercises();
    }
  }

  void _deleteExercise(int index) async {
    setState(() {
      _selectedExercises.removeAt(index);
    });
    _saveExercises();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Workout Routine for ${widget.selectedDate.toLocal().toString().split(' ')[0]}'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _navigateToPredefinedExercises,
            child: Text('Choose Predefined Exercises'),
          ),
          ElevatedButton(
            onPressed: _navigateToAddCustomExercise,
            child: Text('Add My Own Exercise'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedExercises.length,
              itemBuilder: (context, index) {
                final exercise = _selectedExercises[index];
                return ListTile(
                  title: Text(exercise['name'] ?? 'No Name'),
                  subtitle: Text(exercise['description'] ?? 'No Description'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteExercise(index),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseDetailPage(
                          exercise: exercise,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PredefinedExercisesPage extends StatefulWidget {
  @override
  _PredefinedExercisesPageState createState() =>
      _PredefinedExercisesPageState();
}

class _PredefinedExercisesPageState extends State<PredefinedExercisesPage> {
  List<Map<String, dynamic>> _predefinedExercises = [];
  List<Map<String, dynamic>> _filteredExercises = [];
  List<Map<String, dynamic>> _selectedExercises = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchPredefinedExercises();
    _searchController.addListener(_filterExercises);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterExercises);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPredefinedExercises() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('exercices').get();
      setState(() {
        _predefinedExercises = snapshot.docs.map((doc) => doc.data()).toList();
        _filteredExercises = List.from(_predefinedExercises);
      });
    } catch (e) {
      print('Error fetching predefined exercises: $e');
    }
  }

  void _filterExercises() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredExercises = _predefinedExercises
          .where((exercise) =>
              (exercise['name'] ?? '').toLowerCase().contains(query))
          .toList();
    });
  }

  void _toggleExercise(Map<String, dynamic> exercise) {
    setState(() {
      if (_selectedExercises.contains(exercise)) {
        _selectedExercises.remove(exercise);
      } else {
        _selectedExercises.add(exercise);
      }
    });
  }

  void _addExercises() {
    Navigator.pop(context, _selectedExercises);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Predefined Exercises'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Exercises',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _filteredExercises.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredExercises.length,
                    itemBuilder: (context, index) {
                      final exercise = _filteredExercises[index];
                      return ListTile(
                        title: Text(exercise['name'] ?? 'No Name'),
                        subtitle:
                            Text(exercise['description'] ?? 'No Description'),
                        trailing: IconButton(
                          icon: Icon(
                            _selectedExercises.contains(exercise)
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                          ),
                          onPressed: () => _toggleExercise(exercise),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercises,
        child: Icon(Icons.check),
      ),
    );
  }
}

class AddCustomExercisePage extends StatefulWidget {
  final DateTime selectedDate;
  final String username;

  AddCustomExercisePage({required this.selectedDate, required this.username});

  @override
  _AddCustomExercisePageState createState() => _AddCustomExercisePageState();
}

class _AddCustomExercisePageState extends State<AddCustomExercisePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomExercise() async {
    if (_formKey.currentState!.validate()) {
      final customExercise = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'url': _urlController.text,
      };
      await FirebaseFirestore.instance
          .collection('personal_workouts')
          .doc('${widget.selectedDate.toLocal()}_${widget.username}')
          .set({
        'username': widget.username,
        'date': widget.selectedDate,
        'exercises': FieldValue.arrayUnion([customExercise]),
      }, SetOptions(merge: true));

      Navigator.pop(context, customExercise);
    }
  }

  String? _validateUrl(String? value) {
    final urlPattern = r'^(https?:\/\/)?((www\.)?youtube\.com|youtu\.?be)\/.+$';
    final result =
        RegExp(urlPattern, caseSensitive: false).hasMatch(value ?? '');
    if (result) {
      return null;
    } else {
      return 'Please enter a valid YouTube URL';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Custom Exercise'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Exercise Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _urlController,
                decoration: InputDecoration(labelText: 'YouTube URL'),
                validator: _validateUrl,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveCustomExercise,
                child: Text('Save Exercise'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExerciseDetailPage extends StatefulWidget {
  final Map<String, dynamic> exercise;

  ExerciseDetailPage({required this.exercise});

  @override
  _ExerciseDetailPageState createState() => _ExerciseDetailPageState();
}

class _ExerciseDetailPageState extends State<ExerciseDetailPage> {
  late VideoPlayerController _videoController;
  late YoutubePlayerController _youtubeController;
  bool _isYouTube = false;

  @override
  void initState() {
    super.initState();
    final url = widget.exercise['url'] ?? '';
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      _isYouTube = true;
      _youtubeController = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(url) ?? '',
        flags: YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );
    } else {
      _videoController = VideoPlayerController.network(url)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    if (_isYouTube) {
      _youtubeController.dispose();
    } else {
      _videoController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise['name'] ?? 'No Name'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isYouTube)
              YoutubePlayer(
                controller: _youtubeController,
                showVideoProgressIndicator: true,
                onReady: () {
                  _youtubeController.addListener(() {});
                },
              )
            else
              _videoController.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: VideoPlayer(_videoController),
                    )
                  : Center(child: CircularProgressIndicator()),
            SizedBox(height: 16),
            Text(
              widget.exercise['name'] ?? 'No Name',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              widget.exercise['description'] ?? 'No Description',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      floatingActionButton: _isYouTube
          ? null
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  _videoController.value.isPlaying
                      ? _videoController.pause()
                      : _videoController.play();
                });
              },
              child: Icon(
                _videoController.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
            ),
    );
  }
}
