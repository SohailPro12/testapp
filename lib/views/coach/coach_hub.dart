import 'package:flutter/material.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/services/crud2/storage.dart';

class YourHubView extends StatelessWidget {
  const YourHubView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Hub'),
      ),
      body: YourHubBody(),
    );
  }
}

class YourHubBody extends StatefulWidget {
  const YourHubBody({Key? key}) : super(key: key);

  @override
  _YourHubBodyState createState() => _YourHubBodyState();
}

class _YourHubBodyState extends State<YourHubBody> {
  final FireStoreService _fireStoreService = FireStoreService();
  final StorageService _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background banner image
        Positioned.fill(
          child: Image.network(
            'URL_OF_BANNER_IMAGE',
            fit: BoxFit.cover,
          ),
        ),
        // Coach profile photo and full name
        const Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('URL_OF_PROFILE_PHOTO'),
              ),
              SizedBox(height: 8),
              Text(
                'Coach Full Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Floating action button for posting
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              // Implement functionality to post videos or images
            },
            child: Icon(Icons.add),
          ),
        ),
        // Display uploaded videos and images here
        Positioned(
          top: 200,
          bottom: 80,
          left: 0,
          right: 0,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Example of video post
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey, // Placeholder for video
                  child: Center(
                    child: Text(
                      'Video Title',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Example of image post
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey, // Placeholder for image
                  child: Center(
                    child: Text(
                      'Image Title',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
