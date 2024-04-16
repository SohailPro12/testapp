import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:testapp/services/chat/chat_service.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/views/normal/Messages/send_message_view.dart';

class ConversationListPage extends StatelessWidget {
  final ChatService _chatService = ChatService();
  final FireStoreService _fireStoreService = FireStoreService();

  ConversationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future<String> fetchUsername() async {
      try {
        final FireStoreService fireStoreService = FireStoreService();
        String username = await fireStoreService.getUserField('username');
        return username;
      } catch (e) {
        return e.toString();
      }
    }

    Future<String> fetchFullname(String receiverUsername) async {
      try {
        final FireStoreService fireStoreService = FireStoreService();
        String fullName = await fireStoreService.getUserFieldByUsername(
            'full_name', receiverUsername);
        return fullName;
      } catch (e) {
        return e.toString();
      }
    }

    return FutureBuilder<String>(
      future: fetchUsername(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          String currentUser =
              snapshot.data!; // Correctly using the result of fetchUsername()
          return Scaffold(
            appBar: AppBar(
              title: const Text('Conversations'),
            ),
            body: StreamBuilder<QuerySnapshot>(
              stream: _chatService
                  .getConversations(currentUser), // Use currentUser here
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot ds = documents[index];
                      List<dynamic> participants = ds['participants'];
                      // Extract the other participant's username
                      String otherUsername = participants.firstWhere(
                          (participant) => participant != currentUser,
                          orElse: () => '');
                      return FutureBuilder<dynamic>(
                        future: _fireStoreService.getFieldByUsernameCollection(
                            "url", otherUsername, 'userProfile'),
                        builder: (context, profileSnapshot) {
                          if (profileSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (profileSnapshot.hasError) {
                            return Text('Error: ${profileSnapshot.error}');
                          } else {
                            String profilePhotoURL =
                                profileSnapshot.data.toString();
                            return FutureBuilder<String>(
                              future: _chatService.getLastMessage(
                                  snapshot.data!.docs[index].id,
                                  snapshot.data!.docs[index]['participants'][0],
                                  snapshot.data!.docs[index]['participants']
                                      [1]),
                              builder: (context, messageSnapshot) {
                                if (messageSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (messageSnapshot.hasError) {
                                  return Text(
                                      'Error: ${messageSnapshot.error}');
                                } else {
                                  String lastMessage =
                                      messageSnapshot.data ?? '';
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(profilePhotoURL),
                                    ),
                                    title: FutureBuilder<String>(
                                      future: fetchFullname(otherUsername),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<String> snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          return Text(snapshot.data ?? '');
                                        }
                                      },
                                    ),
                                    subtitle: Text(lastMessage),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                            receiverUsername: otherUsername,
                                            currentUsername: currentUser,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                            );
                          }
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          );
        }
      },
    );
  }
}
