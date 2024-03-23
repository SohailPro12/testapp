import 'package:flutter/material.dart';
import 'package:testapp/services/crud2/firestore.dart';

final FireStoreService _fireStoreService = FireStoreService();

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});
  Future<String> getBio() => _fireStoreService.getUserField('Bio');
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      width: MediaQuery.of(context).size.width * 1,
      child: Card(
        margin: const EdgeInsets.only(
          top: 20,
          bottom: 20,
          right: 20,
          left: 20,
        ),
        color: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(30),
          child: FutureBuilder<String>(
            future: getBio(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Show a loading indicator while waiting for the future to complete
              } else if (snapshot.hasError) {
                return Text(
                    'Error: ${snapshot.error}'); // Show error message if the future completes with an error
              } else {
                return Text(
                  snapshot.data ??
                      'No bio available', // Use the data from the future, or a default message if data is null
                  style: const TextStyle(color: Colors.black),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
