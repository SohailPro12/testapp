import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:testapp/models/message.dart';
import 'package:testapp/models/reaction.dart';
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
        reactions: [], // Initialize reactions list
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

  Future<void> sendReaction(
      String chatRoomID, String messageId, String reactionType) async {
    try {
      // Get the current username
      final FireStoreService fireStoreService = FireStoreService();
      String currentUsername = await fireStoreService.getUserField('username');
      print(chatRoomID);
      print(currentUsername);

      // Get a reference to the message document
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final DocumentReference messageRef = firestore
          .collection('chatRooms')
          .doc(chatRoomID) // Adjust with your chatRoomID
          .collection('messages')
          .doc(messageId); // Adjust with your messageId

      // Check if the user has already reacted to this message
      DocumentSnapshot messageSnapshot = await messageRef.get();
      Map<String, dynamic>? messageData =
          messageSnapshot.data() as Map<String, dynamic>?;

      if (messageData != null && messageData.containsKey('reactions')) {
        List<dynamic> reactions = messageData['reactions'];
        bool userReacted = reactions.any((reaction) =>
            reaction['userName'] == currentUsername &&
            reaction['type'] != null);

        if (userReacted) {
          // User has already reacted to this message, update the existing reaction
          List<dynamic> updatedReactions = reactions.map((reaction) {
            if (reaction['userName'] == currentUsername) {
              return {'userName': currentUsername, 'type': reactionType};
            } else {
              return reaction;
            }
          }).toList();

          await messageRef.update({'reactions': updatedReactions});
        } else {
          // User has not reacted to this message yet, add a new reaction
          Map<String, dynamic> newReaction = {
            'userName': currentUsername,
            'type': reactionType,
          };

          List<dynamic> updatedReactions = List.from(reactions)
            ..add(newReaction);

          await messageRef.update({'reactions': updatedReactions});
        }
      } else {
        print("Reaction not updated");
      }
    } catch (e) {
      // Handle error
      print('Error sending reaction: $e');
    }
  }

  Stream<List<Reaction>> getMessageReactions(String messageId) {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Query reactions collection for reactions to the specified message
      return firestore
          .collection('Reactions')
          .where('messageId', isEqualTo: messageId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Reaction.fromMap(doc.data()))
              .toList() as List<Reaction>);
    } catch (e) {
      // Handle error
      print('Error getting message reactions: $e');
      throw e; // Re-throw the error
    }
  }
}
