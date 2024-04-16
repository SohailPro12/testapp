import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:testapp/models/message.dart';
import 'package:testapp/services/crud2/firestore.dart';

class ChatService {
  Future<void> sendMessage({
    required String receiverUsername,
    required String message,
    File? imageFile,
    File? videoFile,
  }) async {
    try {
      final FireStoreService fireStoreService = FireStoreService();
      String currentUsername = await fireStoreService.getUserField('username');
      String currentUserEmail = await fireStoreService.getUserField('email');
      Timestamp timestamp = Timestamp.now();

      // Construct chat room ID for the two users
      List<String> participantUsernames = [currentUsername, receiverUsername];
      participantUsernames.sort(); // Sort usernames for consistency
      String chatRoomID = participantUsernames.join('_');

      String? imageUrl;
      String? videoUrl;

      // Upload image to Firebase Storage if available
      if (imageFile != null) {
        imageUrl = await _uploadFileToStorage(imageFile, 'images');
      }

      // Upload video to Firebase Storage if available
      if (videoFile != null) {
        videoUrl = await _uploadFileToStorage(videoFile, 'videos');
      }

      // Create a new message
      Message newMessage = Message(
        senderUserName: currentUsername,
        senderEmail: currentUserEmail,
        receiverUserName: receiverUsername,
        message: message,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        timestamp: timestamp,
        chatRoomID: chatRoomID, // Add chat room ID to the message
      );

      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Add new message to the database
      await firestore
          .collection('chatRooms')
          .doc(chatRoomID)
          .collection('messages')
          .add(newMessage.toMap());
      // Add new message to the database
      await firestore.collection('chatRooms').doc(chatRoomID).set({
        'participants': participantUsernames,
      });
    } catch (e) {
      // Handle error
      print('Error sending message: $e');
    }
  }

  Future<String?> _uploadFileToStorage(File file, String storageFolder) async {
    try {
      final storage = FirebaseStorage.instance;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final reference = storage.ref().child('$storageFolder/$fileName');
      final uploadTask = reference.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading file to storage: $e');
      return null;
    }
  }

  Stream<QuerySnapshot> getMessages(
      String senderUsername, String receiverUsername) {
    List<String> participantUsernames = [senderUsername, receiverUsername];
    participantUsernames.sort(); // Sort usernames for consistency
    String chatRoomID = participantUsernames.join('_');
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    return firestore
        .collection('chatRooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Function to get the list of conversations for a specific user
  Stream<QuerySnapshot> getConversations(String currentUser) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    return firestore
        .collection('chatRooms')
        .where('participants', arrayContains: currentUser)
        .snapshots();
  }

  Future<String> getLastMessage(
      String chatRoomId, String senderUsername, String receiverUsername) async {
    try {
      // Query the messages collection for the specified chat room

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If there are messages, extract the message text
        String lastMessage = querySnapshot.docs.first.get('message');
        return lastMessage;
      } else {
        // If no messages found, return an empty string
        return '';
      }
    } catch (e) {
      // Handle error
      print('Error getting last message: $e');
      return '';
    }
  }

  // delete a message function

  Future<void> deleteMessage(
    String chatRoomId,
    String messageId,
  ) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      // Handle error
      print('Error deleting message: $e');
    }
  }

  Future<void> updateMessage(
      String chatRoomId, String messageId, String newMessage) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .update({'message': newMessage});
    } catch (e) {
      // Handle error
      print('Error updating message: $e');
    }
  }
}
