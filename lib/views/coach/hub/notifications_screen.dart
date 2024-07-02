// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/crud2/firestore.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Future<void> _grantPremiumAccess(String userId) async {
    try {
      // Update the user's document to grant premium access
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'hasPremiumAccess': true,
      });
      await FirebaseFirestore.instance
          .collection('notifications')
          .where('userUsername', isEqualTo: userId)
          .get() // Use .get() to fetch documents matching the query
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({
            'hasPremiumAccess': true,
          });
        }
      });
      print('Premium access granted.');
    } catch (error) {
      print('Failed to grant premium access: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  String username = "";

  void _fetchUsername() async {
    try {
      final FireStoreService fireStoreService = FireStoreService();
      String fetchedUsername = await fireStoreService.getUserField('username');
      print(fetchedUsername);
      setState(() {
        // Now setState is available because we're in a StatefulWidget
        username = fetchedUsername;
      });
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.red,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('coachUsername', isEqualTo: username)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification = notifications[index];
              bool hasPremiumAccess = notification['hasPremiumAccess'] ?? false;

              return ListTile(
                title: Text(notification['message']),
                subtitle: Text(notification['timestamp'].toDate().toString()),
                trailing: ElevatedButton(
                  onPressed: hasPremiumAccess
                      ? null
                      : () {
                          _grantPremiumAccess(notification['userUsername']);
                        },
                  child: Text(
                      hasPremiumAccess ? 'Access Granted' : 'Grant Access'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
