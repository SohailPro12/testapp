import 'package:flutter/material.dart';
import 'package:testapp/services/crud2/firestore.dart';

class ContactSection extends StatelessWidget {
  final String username;

  const ContactSection({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ContactView(username: username);
  }
}

class ContactView extends StatelessWidget {
  final String username;

  const ContactView({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ContactDetail(username: username),
        FutureBuilder<String>(
          future: _fireStoreService.getUserFieldByUsername(
              'Availability', username),
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

  const ContactStatus({Key? key, required this.status}) : super(key: key);

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
              "Availability",
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
  final String username;

  const ContactDetail({Key? key, required this.username}) : super(key: key);

  Future<String> getPhoneNumber() =>
      _fireStoreService.getUserFieldByUsername('phone_number', username);
  Future<String> getEmail() =>
      _fireStoreService.getUserFieldByUsername('email', username);
  Future<String> getWebsite() =>
      _fireStoreService.getUserFieldByUsername('Website', username);
  Future<String> getStatus() =>
      _fireStoreService.getUserFieldByUsername('Availability', username);
  Future<String> getDomain() =>
      _fireStoreService.getUserFieldByUsername('Domain', username);

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
              future: getDomain(),
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
                      "Domain",
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
              future: getWebsite(),
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
                      "Website",
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
