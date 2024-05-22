/* import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  // create instance of firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  // function to initialize notifications
  Future<void> initializeNotifications() async {
    // request permission for notifications

    await _firebaseMessaging.requestPermission();
    // fetch the FCM token for this device
    final token = await _firebaseMessaging.getToken();
    // print the token (normally it will be sended to the server)
    print('Token: $token');
  }
  // function to handle recieved messages
  // function to initialize foreground and background settings
}
 */