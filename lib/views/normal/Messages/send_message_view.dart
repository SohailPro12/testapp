import 'dart:io';
import 'dart:typed_data';
/* import 'package:flutter/services.dart';
 */
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testapp/services/chat/chat_service.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:video_player/video_player.dart';
//import 'package:gallery_saver/gallery_saver.dart';
import 'package:gal/gal.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
/* import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart'; */

class ChatPage extends StatelessWidget {
  final String currentUsername;
  final String receiverUsername;

  ChatPage({
    Key? key,
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

            return GestureDetector(
              onTap: () {
                if (isImage) {
                  _viewImageDialog(context, data['imageUrl']);
                } else if (isVideo) {
                  _playVideo(context, data['videoUrl']);
                } else {
                  _showOptionsDialog(
                    context,
                    messages[index].id,
                    chatRoomID,
                    data['message'],
                    isImage,
                    isVideo,
                    isCurrentUser,
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: isCurrentUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: isCurrentUser
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      children: [
                        Container(
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
                        if (isImage || isVideo)
                          IconButton(
                            onPressed: () {
                              // Show options dialog
                              _showOptionsDialog(
                                context,
                                messages[index].id,
                                chatRoomID,
                                data['imageUrl'] ?? data['videoUrl'],
                                isImage,
                                isVideo,
                                isCurrentUser,
                              );
                            },
                            icon: Icon(Icons.more_vert),
                          ),
                      ],
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

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Enter your message',
                        border: InputBorder.none,
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: _pickImage,
                              icon: Icon(Icons.image),
                              color: Colors.grey[600],
                            ),
                            IconButton(
                              onPressed: _pickVideo,
                              icon: Icon(Icons.videocam),
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            onPressed: sendMessage,
            icon: Icon(Icons.send),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  void _showReactionPicker(
      BuildContext context, String chatRoomId, String messageId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Material(
          child: EmojiPicker(
            onEmojiSelected: (category, emoji) {
              _chatService.sendReaction(chatRoomId, messageId, emoji.name);
              Navigator.pop(context); // Close the dialog
            },
          ),
        );
      },
    );
  }

  void _showOptionsDialog(
    BuildContext context,
    String messageId,
    String chatRoomID,
    String message,
    bool isImage,
    bool isVideo,
    bool isCurrentUser,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCurrentUser && !isImage && !isVideo)
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
              if (isCurrentUser && !isImage && !isVideo)
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Message'),
                  onTap: () {
                    _editMessage(context, messageId, chatRoomID, message);
                  },
                ),
              if (!isCurrentUser && !isImage && !isVideo)
                ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text('React to Message'),
                  onTap: () {
                    _showReactionPicker(context, chatRoomID, messageId);
                  },
                ),
              if (isImage || isVideo)
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Download Media'),
                  onTap: () {
                    _downloadFile(message);
                    Navigator.pop(context); // Close the dialog
                  },
                ),
              if (isImage || isVideo)
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
            ],
          ),
        );
      },
    );
  }

  void _downloadFile(String fileUrl) async {
    // Check if the file is an image or a video based on its URL
    print(fileUrl);
    if (fileUrl.contains('.jpg') || fileUrl.contains('.png')) {
      // It's an image
      //await GallerySaver.saveImage(fileUrl);
      print(fileUrl);
      //await Gal.putImage(fileUrl);
      // Import the image_gallery_saver package

      await ImageGallerySaver.saveImage(fileUrl as Uint8List);
    } else if (fileUrl.contains('.mp4') || fileUrl.contains('.mov')) {
      // It's a video
      //await GallerySaver.saveVideo(fileUrl);
      await Gal.putVideo(fileUrl);
    } else {
      // Unsupported file type
      print('Unsupported file type');
    }
  }
  /*  void _downloadFile(String fileUrl) async {
    try {
      Dio dio = Dio();
      final dir = await getApplicationDocumentsDirectory();
      final savePath = dir.path + '/file.jpg';
      await dio.download(fileUrl, savePath);
      saveToGallery(savePath);
    } catch (e) {
      print('Error downloading file: $e');
    }
  }

  MethodChannel _channel = MethodChannel('save_to_gallery');
  Future<void> saveToGallery(String filePath) async {
    try {
      print(_channel.name);
      await _channel.invokeMethod('saveToGallery', filePath);
    } on PlatformException catch (e) {
      print("Failed to save to gallery: '${e.message}'.");
    }
  } */

  void _editMessage(
    BuildContext context,
    String messageId,
    String chatRoomID,
    String message,
  ) {
    final TextEditingController _editedMessageController =
        TextEditingController(text: message);

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

  void _viewImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Image.network(imageUrl),
        );
      },
    );
  }

  void _playVideo(BuildContext context, String videoUrl) async {
    final VideoPlayerController _controller =
        VideoPlayerController.network(videoUrl);

    await _controller.initialize();
    _controller.play();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              if (_controller.value.isPlaying) {
                _controller.pause();
              } else {
                _controller.play();
              }
            },
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(_controller),
                  VideoProgressIndicator(_controller, allowScrubbing: true),
                ],
              ),
            ),
          ),
        );
      },
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
}
