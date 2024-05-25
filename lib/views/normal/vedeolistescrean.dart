import 'package:flutter/material.dart';
import 'package:testapp/views/normal/Exrcice.dart';
import 'package:testapp/views/normal/VideoPlayerScreen.dart';

class VideoListScreen extends StatefulWidget {
  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<Exercise> videoDetails = [];

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    List<Exercise> videos = await getExercices();
    setState(() {
      videoDetails = videos;
    });
  }

  void _showAddVideoDialog() {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController videoUrlController = TextEditingController();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter une nouvelle vidéo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nom'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: videoUrlController,
                  decoration: InputDecoration(labelText: 'URL de la vidéo'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () async {
                Exercise newExercise = Exercise(
                  name: nameController.text,
                  description: descriptionController.text,
                  videoUrl: videoUrlController.text,
                  id: '',
                );
                await addExercise(newExercise);
                Navigator.of(context).pop();
                fetchVideos(); // Rafraîchir la liste des vidéos après l'ajout
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des vidéos'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed:
                _showAddVideoDialog, // Afficher la boîte de dialogue d'ajout de vidéo
          ),
        ],
      ),
      body: videoDetails.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: videoDetails.length,
              itemBuilder: (context, index) {
                Exercise exercise = videoDetails[index];
                return ListTile(
                  title: Text(exercise.name),
                  subtitle: Text(exercise.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VideoPlayerScreen(exercise: exercise),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
