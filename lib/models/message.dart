import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderUserName;
  final String senderEmail;
  final String receiverUserName;
  final String message;
  final Timestamp timestamp;
  final String chatRoomID;
  final String? imageUrl;
  final String? videoUrl;

  Message({
    required this.senderUserName,
    required this.senderEmail,
    required this.receiverUserName,
    required this.message,
    required this.timestamp,
    required this.chatRoomID,
    this.imageUrl = '',
    this.videoUrl = '',
  });

  //convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderUserName': senderUserName,
      'senderEmail': senderEmail,
      'receiverUserName': receiverUserName,
      'message': message,
      'timestamp': timestamp,
      'chatRoomID': chatRoomID,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
    };
  }
}
