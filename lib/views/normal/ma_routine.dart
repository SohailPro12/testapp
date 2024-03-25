import 'package:flutter/material.dart';

class WeeklyPlanner extends StatelessWidget {
  const WeeklyPlanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(' plan of the week '),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'Plan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('lundi'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Mardi'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Mercredi'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Jeudi'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Vendredi'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Samedi'),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Demanche'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
