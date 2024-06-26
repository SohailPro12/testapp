import 'package:flutter/material.dart';
import 'package:testapp/services/crud2/firestore.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const ContactView();
  }
}

class ContactView extends StatelessWidget {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ContactDetail(),
        FutureBuilder<String>(
          future: _fireStoreService.getUserField('country'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Show loading indicator while waiting
            } else if (snapshot.hasError) {
              return Text(
                  'Error: ${snapshot.error}'); // Show error message if any
            } else {
              return ContactStatus(status: snapshot.data ?? '');
            }
          },
        ),
      ],
    );
  }
}

class ContactStatus extends StatelessWidget {
  final String status;

  const ContactStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blueGrey),
            title: const Text(
              "Country",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              status,
              style: const TextStyle(color: Colors.black),
            ),
            dense: true,
          ),
        ],
      ),
    );
  }
}

final FireStoreService _fireStoreService = FireStoreService();

class ContactDetail extends StatelessWidget {
  const ContactDetail({super.key});

  Future<String> getPhoneNumber() =>
      _fireStoreService.getUserField('phone_number');
  Future<String> getEmail() => _fireStoreService.getUserField('email');
  Future<String> getFavoritSport() =>
      _fireStoreService.getUserField('favorite_sport');
  Future<String> getLevel() => _fireStoreService.getUserField('level');

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(20),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            FutureBuilder<String>(
              future: getPhoneNumber(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show loading indicator while waiting
                } else if (snapshot.hasError) {
                  return Text(
                      'Error: ${snapshot.error}'); // Show error message if any
                } else {
                  return ListTile(
                    leading:
                        const Icon(Icons.phone_android, color: Colors.blueGrey),
                    title: const Text(
                      "Mobile",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      snapshot.data ?? '', // Use the resolved data
                      style: const TextStyle(color: Colors.black),
                    ),
                    dense: true,
                  );
                }
              },
            ),
            FutureBuilder<String>(
              future: getEmail(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show loading indicator while waiting
                } else if (snapshot.hasError) {
                  return Text(
                      'Error: ${snapshot.error}'); // Show error message if any
                } else {
                  return ListTile(
                    leading: const Icon(Icons.mail, color: Colors.blueGrey),
                    title: const Text(
                      "Email",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      snapshot.data ?? '', // Use the resolved data
                      style: const TextStyle(color: Colors.black),
                    ),
                    dense: true,
                  );
                }
              },
            ),
            FutureBuilder<String>(
              future: getFavoritSport(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show loading indicator while waiting
                } else if (snapshot.hasError) {
                  return Text(
                      'Error: ${snapshot.error}'); // Show error message if any
                } else {
                  return ListTile(
                    leading: const Icon(Icons.fitness_center,
                        color: Colors.blueGrey),
                    title: const Text(
                      "Favorit Sport",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      snapshot.data ?? '', // Use the resolved data
                      style: const TextStyle(color: Colors.black),
                    ),
                    dense: true,
                  );
                }
              },
            ),
            FutureBuilder<String>(
              future: getLevel(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show loading indicator while waiting
                } else if (snapshot.hasError) {
                  return Text(
                      'Error: ${snapshot.error}'); // Show error message if any
                } else {
                  return ListTile(
                    leading:
                        const Icon(Icons.web_asset, color: Colors.blueGrey),
                    title: const Text(
                      "Level",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      snapshot.data ?? '', // Use the resolved data
                      style: const TextStyle(color: Colors.black),
                    ),
                    dense: true,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
