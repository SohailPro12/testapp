import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/models/post.dart';
import 'package:testapp/services/crud2/storage.dart';
import 'package:testapp/views/coach/hub/add_post.dart';
import 'package:testapp/views/coach/hub/coach_posts.dart';
import 'package:testapp/views/coach/hub/notifications_screen.dart';
import 'package:testapp/views/coach/hub/post_desc.dart';
import 'package:testapp/views/coach/profile/coach_profile_view.dart';
import 'package:testapp/views/coach/profile/utils.dart';

class YourHubView extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const YourHubView({Key? key});

  Future<void> _showPostOptionsDialog(
      BuildContext context, String username) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Post Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPostScreen(
                        username: username,
                        collectionName: 'HubPosts',
                        postType: PostType.image,
                      ),
                    ),
                  );
                },
                child: const Text("Post Image"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddPostScreen(
                        username: username,
                        collectionName: 'HubPosts',
                        postType: PostType.video,
                      ),
                    ),
                  );
                },
                child: const Text("Post Video"),
              ),
            ],
          ),
        );
      },
    );
  }

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Hub'),
        backgroundColor: const Color.fromARGB(255, 243, 72, 33),
      ),
      body: const YourHubBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fetchUsername().then((username) {
            _showPostOptionsDialog(context, username);
          });
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.workspace_premium),
            label: 'Premium',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
        ],
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          if (index == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NotificationScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const YourPostsView(typePosts: 'premium')),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CoachProfileView()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const YourPostsView()),
            );
          }
        },
      ),
    );
  }
}

class YourHubBody extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const YourHubBody({Key? key});

  @override
  // ignore: library_private_types_in_public_api
  _YourHubBodyState createState() => _YourHubBodyState();
}

class _YourHubBodyState extends State<YourHubBody> {
  final FireStoreService _fireStoreService = FireStoreService();

  String _profileImageUrl = '';
  String _bannerImageUrl = '';
  String _fullName = '';
  String _username = '';

  final List<Post> _posts = [];

  void _fetchPosts(String username) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('HubPosts')
          .where('username', isEqualTo: username)
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
          _numberOfPosts = 0; // Update the number of posts
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching posts: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUsername();
  }

  void _fetchUsername() async {
    try {
      String username = await _fireStoreService.getUserField('username');

      int numberOfFollowers =
          await _fireStoreService.getFieldByUsernameCollection(
                  "followers", username, "userProfile") ??
              0;
      // ignore: avoid_print
      print(numberOfFollowers);

      setState(() {
        _username = username;
        _numberOfFollowers = numberOfFollowers;
        _fetchPosts(_username);
      });
      _fetchProfileImage();
      _fetchFullName();
      _fetchBannerImage();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching username: $e');
    }
  }

  int _numberOfFollowers = 0;
  int _numberOfPosts = 0;

  void _fetchProfileImage() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userProfile')
        .where('username', isEqualTo: _username)
        .where('datatype', isEqualTo: 'profilePicture')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _profileImageUrl = querySnapshot.docs.first.get('url');
      });
    }
  }

  void _fetchFullName() async {
    try {
      String fullName = await _fireStoreService.getUserField('full_name');
      setState(() {
        _fullName = fullName;
      });
    } catch (e) {
      print('Error fetching full name: $e');
    }
  }

  void _fetchBannerImage() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userProfile')
        .where('username', isEqualTo: _username)
        .where('banner', isEqualTo: 'banner')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _bannerImageUrl = querySnapshot.docs.first.get('bannerurl');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
              bottom: 10,
              right: 10,
              child: IconButton(
                onPressed: () {
                  _uploadImage(context, _username);
                },
                icon: const Icon(Icons.add_a_photo),
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
                  child:
                      _profileImageUrl.isEmpty ? const Text('No Photo') : null,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                'Welcome to your hub, Coach $_fullName!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
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
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Your Latest Posts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _posts.isEmpty
                    ? const Center(child: Text('No posts available.'))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            Post post = _posts[index];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PostInfoView(
                                        post:
                                            post), // Pass the post to the PostInfo view
                                  ),
                                );
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Card(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Banner image or video thumbnail
                                      post.datatype == 'video'
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
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _uploadImage(BuildContext context, String username) async {
  Uint8List? image = await pickImage(ImageSource.gallery);
  if (image != null) {
    StorageService storageService = StorageService();
    String response = await storageService.saveData(
      username: username,
      datatype: "banner",
      file: image,
    );
    if (response == "The banner  was saved successfully") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('banner uploaded successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('banner to upload image: $response')),
      );
    }
  }
}
