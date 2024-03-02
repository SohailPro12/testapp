import 'package:flutter/material.dart';

class UserHomeView extends StatelessWidget {
  final String userName;

  const UserHomeView({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome, $userName!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to user profile
              },
              icon: const Icon(Icons.person),
              label: const Text('Profile'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to create routine
              },
              child: const Text('Créer ma routine'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Routine prédéfinie',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Add predefined routines section here
            const Spacer(),
            FloatingActionButton(
              onPressed: () {
                // Navigate to coach view
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.message),
            ),
          ],
        ),
      ),
    );
  }
}
