import 'package:flutter/material.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/views/coach/profile/edit_bio_view.dart';

final FireStoreService _fireStoreService = FireStoreService();

class AboutSection extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const AboutSection({Key? key});

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
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditBioScreen(initialBio: snapshot.data ?? ''),
                      ),
                    );
                  },
                  child: Text(
                    snapshot.data ?? 'No bio available',
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
