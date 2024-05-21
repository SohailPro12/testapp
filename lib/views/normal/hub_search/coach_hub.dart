import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testapp/services/auth/firebase_auth_provider.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/models/post.dart';
import 'package:testapp/views/normal/Messages/send_message_view.dart';
import 'package:testapp/views/normal/hub_search/post_desc.dart';

class RequiredUserNameCoachHubView extends StatelessWidget {
  final String username;

  const RequiredUserNameCoachHubView({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Hub'),
      ),
      body: CoachHubBody(username: username),
    );
  }
}

class CoachHubBody extends StatefulWidget {
  final String username;

  const CoachHubBody({super.key, required this.username});

  @override
  // ignore: library_private_types_in_public_api
  _CoachHubBodyState createState() => _CoachHubBodyState();
}

class _CoachHubBodyState extends State<CoachHubBody> {
  List<Post> _posts = [];
  String _profileImageUrl = '';
  String _bannerImageUrl = '';
  int _numberOfFollowers = 0;
  int _numberOfPosts = 0;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _fetchProfileImage();
    _fetchBannerImage();
    _fetchFollowers();
    _fetchFullName();
    _checkIfFollowing();
    _fetchUserId();
    _fetchUsername();
  }

  String _username = "";
  void _fetchUsername() async {
    try {
      String username = await _fireStoreService.getUserField('username');
      setState(() {
        _username = username;
      });
      ;
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  void _fetchPosts() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('HubPosts')
          .where('username', isEqualTo: widget.username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _posts.clear();

        for (var doc in querySnapshot.docs) {
          _posts.add(Post.fromSnap(doc));
        }

        setState(() {
          _numberOfPosts = _posts.length; // Update the number of posts
        });
      } else {
        setState(() {
          _numberOfPosts = 0;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching posts: $e');
    }
  }

  void _fetchProfileImage() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userProfile')
        .where('username', isEqualTo: widget.username)
        .where('datatype', isEqualTo: 'profilePicture')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _profileImageUrl = querySnapshot.docs.first.get('url');
      });
    }
  }

  void _fetchBannerImage() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userProfile')
        .where('username', isEqualTo: widget.username)
        .where('banner', isEqualTo: 'banner')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _bannerImageUrl = querySnapshot.docs.first.get('bannerurl');
      });
    }
  }

  void _fetchFollowers() async {
    try {
      DocumentSnapshot userProfileDoc = await FirebaseFirestore.instance
          .collection('userProfile')
          .doc(widget.username)
          .get();

      if (userProfileDoc.exists) {
        setState(() {
          _numberOfFollowers = userProfileDoc.get('followers') ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching followers: $e');
    }
  }

  void _checkIfFollowing() async {
    try {
      DocumentSnapshot userProfileDoc = await FirebaseFirestore.instance
          .collection('userProfile')
          .doc(widget.username)
          .get();
      String username = await fetchUsername();

      if (userProfileDoc.exists) {
        String currentUser = username; // Replace with actual current user ID
        List<dynamic> followers = userProfileDoc.get('followerList') ?? [];
        if (followers.contains(currentUser)) {
          setState(() {
            _isFollowing = true;
          });
        }
      }
    } catch (e) {
      print('Error checking if following: $e');
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

  void _toggleFollow() async {
    try {
      String username = await fetchUsername();
      String currentUser = username; // Replace with actual current user ID
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('userProfile')
          .doc(widget.username);

      if (_isFollowing) {
        // Unfollow
        await userDocRef.update({
          'followers': FieldValue.increment(-1),
          'followerList': FieldValue.arrayRemove([currentUser]),
        });
      } else {
        // Follow
        await userDocRef.update({
          'followers': FieldValue.increment(1),
          'followerList': FieldValue.arrayUnion([currentUser]),
        });
      }

      setState(() {
        _isFollowing = !_isFollowing;
        _numberOfFollowers = _isFollowing
            ? _numberOfFollowers + 1
            : _numberOfFollowers - 1; // Update the number of followers
      });
    } catch (e) {
      print('Error toggling follow: $e');
    }
  }

  // Fetch full name
  String _fullName = "";
  final FireStoreService _fireStoreService = FireStoreService();
  void _fetchFullName() async {
    try {
      String fullName = await _fireStoreService.getFieldByUsernameCollection(
          "full_name", widget.username, "users");
      setState(() {
        _fullName = fullName;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching full name: $e');
    }
  }

  String _userId = "";
  void _fetchUserId() async {
    // Fetch coach ID
    try {
      String userId = FirebaseAuthProvider().currentUser!.id;
      setState(() {
        _userId = userId;
      });
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching user ID: $e');
    }
  }

  void _sendNotification(String coachUsername, String userUsername) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'coachUsername': coachUsername,
        'userUsername': userUsername,
        'timestamp': FieldValue.serverTimestamp(),
        'message': '$userUsername wants to view premium posts.',
        'type': 'premium_request',
      });
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              SizedBox(
                height: 200,
                child: _bannerImageUrl.isNotEmpty
                    ? Image.network(
                        _bannerImageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
                        color: Colors.grey,
                        child: const Center(
                          child: Text(
                            'Banner Image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width / 2 - 50,
                bottom: 0,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color.fromARGB(255, 227, 126, 126),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImageUrl.isNotEmpty
                        ? NetworkImage(_profileImageUrl)
                        : null,
                    child: _profileImageUrl.isEmpty
                        ? const Text('No Photo')
                        : null,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          receiverUsername: widget.username,
                          currentUsername: _username,
                        ),
                      ),
                    );
                  },
                  child: const Text('Send a Message'),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _toggleFollow,
                  icon: Icon(
                    _isFollowing ? Icons.check : Icons.add,
                    color: _isFollowing ? Colors.green : null,
                  ),
                  label: Text(_isFollowing ? 'Following' : 'Follow'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people),
                    const SizedBox(width: 8),
                    Text(
                      '$_numberOfFollowers',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.post_add),
                    const SizedBox(width: 8),
                    Text(
                      '$_numberOfPosts',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.75, // Adjust the aspect ratio as needed
            ),
            itemCount: _posts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              Post post = _posts[index];
              return InkWell(
                onTap: () async {
                  if (post.description.toLowerCase().contains('premium')) {
                    // Handle premium post tap
                    _sendNotification(widget.username, _username);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'This is a premium post. The coach has been notified.'),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostInfoView(post: post),
                      ),
                    );
                  }
                },
                child: Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner image or custom premium poster
                      post.description.toLowerCase().contains('premium')
                          ? Image.network(
                              "https://i.pinimg.com/564x/57/8d/ce/578dce73c62f671aa14eff34b6c12509.jpg",
                              fit: BoxFit.cover,
                            )
                          : post.datatype == 'video'
                              ? AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.network(
                                    "https://i.pinimg.com/564x/e0/a2/00/e0a200b80d2aa7282c3987991aaf328b.jpg",
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.network(
                                  post.postUrl,
                                  fit: BoxFit.cover,
                                ),
                      const SizedBox(height: 8),
                      // Description
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          post.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
