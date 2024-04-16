import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testapp/services/chat/chat_service.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:gallery_saver/gallery_saver.dart';

class ChatPage extends StatelessWidget {
  final String currentUsername;
  final String receiverUsername;

  ChatPage({
    super.key,
    required this.receiverUsername,
    required this.currentUsername,
  });

  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();

  void sendMessage({File? imageFile, File? videoFile}) async {
    String? messageText = _messageController.text.trim();
    if (messageText.isEmpty && imageFile == null && videoFile == null) {
      // No message or file to send
      return;
    }

    await _chatService.sendMessage(
      receiverUsername: receiverUsername,
      message: messageText,
      imageFile: imageFile,
      videoFile: videoFile,
    );
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    Future<String> fetchFullname() async {
      try {
        final FireStoreService fireStoreService = FireStoreService();
        String fullName = await fireStoreService.getUserFieldByUsername(
          'full_name',
          receiverUsername,
        );
        return fullName;
      } catch (e) {
        return e.toString();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: fetchFullname(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return Text(snapshot.data ?? '');
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(currentUsername, receiverUsername),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Reverse the order of messages
        List<DocumentSnapshot> messages = snapshot.data!.docs.reversed.toList();

        return ListView.builder(
          reverse: true, // Reverse the ListView to scroll to the last messages
          itemCount: messages.length,
          itemBuilder: (BuildContext context, int index) {
            Map<String, dynamic> data =
                messages[index].data() as Map<String, dynamic>;
            final sender = data['senderUserName'];
            final chatRoomID = data['chatRoomID']; // Extract chat room ID

            // Check if the sender is the current user
            final bool isCurrentUser = sender == currentUsername;

            // Determine message type
            final bool isImage = data['imageUrl'] != null;
            final bool isVideo = data['videoUrl'] != null;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: GestureDetector(
                onTap: () {
                  if (isImage) {
                    // Open image in a dialog
                    _viewImageDialog(context, data['imageUrl']);
                  } else if (isVideo) {
                    // Play video
                    // You can implement video player here
                    _playVideo(context, data['videoUrl']);
                  }
                },
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isImage)
                              Image.network(
                                data['imageUrl'],
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            if (isVideo)
                              AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Container(
                                  color: Colors.black,
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ),
                                ),
                              ),
                            if (!isImage && !isVideo)
                              Text(
                                data['message'],
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (isImage || isVideo)
                      IconButton(
                        onPressed: () {
                          // Download image or video
                          _downloadFile(data['imageUrl'] ?? data['videoUrl']);
                        },
                        icon: Icon(Icons.download),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _downloadFile(String fileUrl) async {
    // Check if the file is an image or a video based on its URL
    print(fileUrl);
    if (fileUrl.contains('.jpg') || fileUrl.contains('.png')) {
      // It's an image
      await GallerySaver.saveImage(fileUrl);
    } else if (fileUrl.contains('.mp4') || fileUrl.contains('.mov')) {
      // It's a video
      await GallerySaver.saveVideo(fileUrl);
    } else {
      // Unsupported file type
      print('Unsupported file type');
    }
  }

  void _showOptionsDialog(
    BuildContext context,
    String messageId,
    String chatRoomID,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Message'),
                onTap: () {
                  _chatService.deleteMessage(
                    chatRoomID,
                    messageId,
                  ); // Delete message
                  Navigator.pop(context); // Close the dialog
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Message'),
                onTap: () {
                  _editMessage(context, messageId, chatRoomID); // Edit message
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editMessage(
    BuildContext context,
    String messageId,
    String chatRoomID,
  ) {
    final TextEditingController _editedMessageController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Message'),
          content: TextField(
            controller:
                _editedMessageController, // Use the existing message as initial value
            decoration: const InputDecoration(hintText: 'Enter edited message'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Call the edit message method in chat service
                _chatService.updateMessage(
                  chatRoomID,
                  messageId,
                  _editedMessageController.text,
                );
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your message',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                    ),
                    IconButton(
                      onPressed: _pickVideo,
                      icon: const Icon(Icons.videocam),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Call sendMessage method with imageFile parameter
      sendMessage(imageFile: imageFile);
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      File videoFile = File(pickedFile.path);
      // Call sendMessage method with videoFile parameter
      sendMessage(videoFile: videoFile);
    }
  }

  void _viewImageDialog(BuildContext context, data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Image.network(data),
        );
      },
    );
  }

  void _playVideo(context, String videoUrl) async {
    // Initialize the video player controller
    final VideoPlayerController _controller =
        // ignore: deprecated_member_use
        VideoPlayerController.network(videoUrl);

    // Initialize the video player and load the video
    await _controller.initialize();

    // Play the video
    _controller.play();

    // Optionally, you can show the video player in a dialog or a new screen
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        );
      },
    );
  }
}
