import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testapp/services/crud2/firestore.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String> fetchUsername() async {
    try {
      final FireStoreService fireStoreService = FireStoreService();
      String username = await fireStoreService.getUserField('username');
      return username;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> initialize() async {
    // Request permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get the token
      String? token = await _firebaseMessaging.getToken();
      print("FCM Token: $token");

      // Save the token to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(await fetchUsername()) // Replace with the actual user ID
          .update({'fcmToken': token});
    }

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message while in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    // Listen for background messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked!');
    });
  }
}
