import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testapp/services/crud2/storage.dart';
import 'package:video_player/video_player.dart';

enum PostType { image, video }

class AddPostScreen extends StatefulWidget {
  final String username;
  final String collectionName;
  final PostType postType;

  const AddPostScreen({
    super.key,
    required this.username,
    required this.collectionName,
    required this.postType,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  late TextEditingController _descriptionController;
  Uint8List? _uploadedFileBytes;
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Enter ${widget.postType == PostType.image ? "Image" : "Video"} Description'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Wrap your Column with SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Enter description',
                ),
                maxLines: null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickFile,
                child: Text(
                    'Add ${widget.postType == PostType.image ? "Image" : "Video"}'),
              ),
              if (_uploadedFileBytes != null &&
                  widget.postType == PostType.image) ...[
                const SizedBox(height: 16),
                Image.memory(_uploadedFileBytes!),
              ],
              if (_videoController != null &&
                  widget.postType == PostType.video) ...[
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(_videoController!),
                      VideoProgressIndicator(
                        _videoController!,
                        allowScrubbing: true,
                        padding: const EdgeInsets.all(8),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(_videoController!.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow),
                            onPressed: () {
                              setState(() {
                                if (_videoController!.value.isPlaying) {
                                  _videoController!.pause();
                                } else {
                                  _videoController!.play();
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.replay),
                            onPressed: () {
                              setState(() {
                                _videoController!.seekTo(Duration.zero);
                                _videoController!.play();
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              if (_uploadedFileBytes != null) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _uploadFile,
                  child: const Text('Upload Post'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    Uint8List? fileBytes;
    if (widget.postType == PostType.image) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        fileBytes = await pickedFile.readAsBytes();
      }
    } else {
      final pickedFile =
          await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        fileBytes = await pickedFile.readAsBytes();
        _videoController = VideoPlayerController.file(
          File(pickedFile.path), // Create a File object from the file path
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
        )..initialize().then((_) {
            setState(() {});
            _videoController!.play();
          });
      }
    }

    if (fileBytes != null) {
      setState(() {
        _uploadedFileBytes = fileBytes;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Description cannot be empty')),
      );
      return;
    }

    if (_uploadedFileBytes != null) {
      final datatype = widget.postType == PostType.image ? 'image' : 'video';
      final storageService = StorageService();
      final response = await storageService.uploadPost(
        datatype: datatype,
        collectionName: widget.collectionName,
        username: widget.username,
        file: _uploadedFileBytes!,
        description: _descriptionController.text.trim(),
      );

      if (response != "success") {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload post: $response')),
        );
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pop(context); // Return to previous screen
      }
    }
  }
}
