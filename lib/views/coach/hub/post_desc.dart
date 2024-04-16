// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/views/coach/usersearchprofile/user_profile_view.dart';
import 'package:video_player/video_player.dart';
import 'package:testapp/models/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PostInfoView extends StatefulWidget {
  final Post post;
  // ignore: use_super_parameters
  const PostInfoView({Key? key, required this.post}) : super(key: key);

  @override
  _PostInfoViewState createState() => _PostInfoViewState();
}

class _PostInfoViewState extends State<PostInfoView> {
  late VideoPlayerController _videoController;
  bool _isLiked = false;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.post.datatype == 'video') {
      // ignore: deprecated_member_use
      _videoController = VideoPlayerController.network(widget.post.postUrl)
        ..initialize().then((_) {
          setState(() {});
        });
    }
    _fetchLikesCount();
    _fetchProfileImage();
  }

  @override
  void dispose() {
    if (widget.post.datatype == 'video') {
      _videoController.dispose();
    }
    super.dispose();
  }

  void _fetchLikesCount() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('HubPosts')
          .doc(widget.post.postId)
          .collection('likes')
          .get();
      setState(() {
        _likesCount = querySnapshot.size;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching likes count: $e');
    }
  }

  Future<String> fetchUsername() async {
    try {
      final FireStoreService fireStoreService = FireStoreService();
      String username = await fireStoreService.getUserField('username');
      return username;
    } catch (e) {
      return e.toString();
    }
  }

  void _handleLike() async {
    try {
      String username = await fetchUsername();
      // Check if the user has already liked the post
      DocumentSnapshot postDoc = await FirebaseFirestore.instance
          .collection('HubPosts')
          .doc(widget.post.postId)
          .get();

      if (postDoc.exists) {
        int likes = postDoc['likes'] ?? 0;

        // Check if the user has already liked the post
        DocumentSnapshot likeDoc = await FirebaseFirestore.instance
            .collection('HubPosts')
            .doc(widget.post.postId)
            .collection('likes')
            .doc(username) // Replace 'userId' with the actual user ID
            .get();

        if (likeDoc.exists) {
          // If user already liked, remove the like
          await likeDoc.reference.delete();
          likes--;
        } else {
          // If user hasn't liked, add the like
          await FirebaseFirestore.instance
              .collection('HubPosts')
              .doc(widget.post.postId)
              .collection('likes')
              .doc(username) // Replace 'userId' with the actual user ID
              .set({'likedAt': DateTime.now()});
          likes++;
        }

        // Update the 'likes' field in the post document
        await postDoc.reference.update({'likes': likes});

        setState(() {
          _isLiked = !_isLiked;
          _likesCount = likes;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error handling like: $e');
    }
  }

  final TextEditingController _commentController = TextEditingController();

  void _handleComment() async {
    try {
      String username = await fetchUsername();
      String commentText = _commentController.text.trim();
      if (commentText.isNotEmpty) {
        // Add the comment to the post's comments collection
        await FirebaseFirestore.instance
            .collection('HubPosts')
            .doc(widget.post.postId)
            .collection('comments')
            .add({
          'text': commentText,
          'userId': username, // Replace 'userId' with the actual user ID
          'createdAt': Timestamp.now(),
        });

        // Clear the comment text field after submitting
        _commentController.clear();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error adding comment: $e');
    }
  }

  void _handleShare() {
    // Implement share functionality (open share dialog with post URL)
    String shareText =
        'Check out this post: ${widget.post.description}\n${widget.post.postUrl}';
    Share.share(shareText);
  }

  void _handleDelete() async {
    try {
      await FirebaseFirestore.instance
          .collection('HubPosts')
          .doc(widget.post.postId)
          .delete();
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      // ignore: avoid_print
      print('Error deleting post: $e');
    }
  }

  String _profileImageUrl = '';
  void _fetchProfileImage() async {
    String username = await fetchUsername();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userProfile')
        .where('username', isEqualTo: username)
        .where('datatype', isEqualTo: 'profilePicture')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _profileImageUrl = querySnapshot.docs.first.get('url');
      });
    }
  }

  Future<String> fetchFullname() async {
    try {
      final FireStoreService fireStoreService = FireStoreService();
      String fullName = await fireStoreService.getUserField('full_name');
      return fullName;
    } catch (e) {
      return e.toString();
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    return formattedDate;
  }

  Future<Widget> _buildCommentList() async {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('HubPosts')
          .doc(widget.post.postId)
          .collection('comments')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot commentDoc = snapshot.data!.docs[index];
              String commenterId = commentDoc[
                  'userId']; // Get commenter's ID from the comment document
              String commentText = commentDoc[
                  'text']; // Get comment text from the comment document
              Timestamp createdAt = commentDoc[
                  'createdAt']; // Get comment creation timestamp from the comment document

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(commenterId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    Map<String, dynamic> userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    String commenterFullName = userData['full_name'] ??
                        'Unknown'; // Get commenter's full name from users collection

                    // Now fetch the profile image URL from the userProfile collection
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('userProfile')
                          .doc(commenterId)
                          .get(),
                      builder: (context, profileSnapshot) {
                        if (profileSnapshot.hasData &&
                            profileSnapshot.data!.exists) {
                          Map<String, dynamic> profileData =
                              profileSnapshot.data!.data()
                                  as Map<String, dynamic>;
                          String commenterProfileImageUrl = profileData[
                                  'url'] ??
                              ''; // Get commenter's profile image URL from userProfile collection

                          return ListTile(
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  commenterProfileImageUrl.isNotEmpty
                                      ? NetworkImage(commenterProfileImageUrl)
                                      : null,
                              child: commenterProfileImageUrl.isEmpty
                                  ? const Text('No Photo')
                                  : null,
                            ),
                            title: Text(
                                commenterFullName), // Display commenter's full name
                            subtitle: Text(commentText), // Display comment text
                            trailing: Text(
                              _formatTimestamp(
                                  createdAt), // Format and display comment creation timestamp
                              style: const TextStyle(fontSize: 12),
                            ),
                            onTap: () {
                              // Navigate to the profile of the user who commented
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RequiredUsernameProfileView(
                                    username:
                                        commenterId, // Pass commenter's username
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return const ListTile(
                            title: Text(
                                'Unknown'), // Display 'Unknown' if userProfile data is not available
                            subtitle:
                                Text('Commenter profile data not available'),
                          );
                        }
                      },
                    );
                  } else {
                    return const ListTile(
                      title: Text(
                          'Unknown'), // Display 'Unknown' if user data is not available
                      subtitle: Text('Commenter data not available'),
                    );
                  }
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return Text('Error loading comments: ${snapshot.error}');
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display post details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.post.description,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // Display post image or video
            widget.post.datatype == 'video'
                ? _videoController.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoController.value.aspectRatio,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            VideoPlayer(_videoController),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(_videoController.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow),
                                  onPressed: () {
                                    setState(() {
                                      if (_videoController.value.isPlaying) {
                                        _videoController.pause();
                                      } else {
                                        _videoController.play();
                                      }
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.replay),
                                  onPressed: () {
                                    setState(() {
                                      _videoController.seekTo(Duration.zero);
                                      _videoController.play();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : const CircularProgressIndicator()
                : Image.network(
                    widget.post.postUrl,
                    fit: BoxFit.cover,
                  ),
            // Display likes count and buttons
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon:
                        Icon(_isLiked ? Icons.favorite : Icons.favorite_border),
                    color: _isLiked ? Colors.red : null,
                    onPressed: _handleLike,
                  ),
                  Text('$_likesCount'),
                  IconButton(
                    icon: const Icon(Icons.comment),
                    onPressed: _handleComment,
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: _handleShare,
                  ),
                ],
              ),
            ),
            // Display comments
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Comments:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Comment input field
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _handleComment,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
            // Display the list of comments
            FutureBuilder(
              future: _buildCommentList(),
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return snapshot.data ?? Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
