import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PremiumContentScreen extends StatelessWidget {
  final String userId;

  const PremiumContentScreen({Key? key, required this.userId})
      : super(key: key);

  Future<bool> checkPremiumAccess() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('hasPremiumAccess', isEqualTo: true)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkPremiumAccess(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == true) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Premium Content'),
            ),
            body: const Center(
              child: Text('Welcome to premium content!'),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Premium Content'),
            ),
            body: const Center(
              child: Text('You do not have access to premium content.'),
            ),
          );
        }
      },
    );
  }
}
