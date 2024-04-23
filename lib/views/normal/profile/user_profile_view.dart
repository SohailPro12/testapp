import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart'; // Import the share_plus package
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/services/crud2/storage.dart';
import 'package:testapp/views/coach/profile/utils.dart';
import 'package:testapp/views/normal/profile/about.dart';
import 'package:testapp/views/normal/profile/contact.dart';

class UserProfileView extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const UserProfileView({Key? key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

final FireStoreService _fireStoreService = FireStoreService();

class _UserProfileViewState extends State<UserProfileView> {
  List<Tab> tabs = [
    const Tab(
      text: "About",
      icon: Icon(Icons.account_box),
    ),
    const Tab(
      text: "Contact",
      icon: Icon(Icons.contact_page),
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadProfileImage();
    _loadUserData();
  }

  String? _profileImageUrl;

  void loadProfileImage() async {
    String username = await _fireStoreService.getUserField('username');
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userProfile')
        .where('username', isEqualTo: username)
        .where('datatype',
            isEqualTo: 'profilePicture') // Update datatype to 'profilePicture'
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _profileImageUrl = querySnapshot.docs.first.get('url');
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _fireStoreService.getUserField('username'),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show a loading indicator while waiting
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Show error message if any
        } else {
          String username = snapshot.data ??
              ''; // Use the data if available, or a default value
          String profileUrl = 'https://fitme.com/profile/$username';

          return DefaultTabController(
            length: tabs.length,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: const Color.fromARGB(255, 200, 202, 70),
                titleTextStyle: const TextStyle(
                  color: Colors.white,
                ),
                toolbarHeight: 275,
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 25),
                    Center(child: profilePhotos()),
                    const SizedBox(height: 15),
                    profileName(),
                    const SizedBox(height: 5),
                    hobbies(),
                    const SizedBox(height: 10),
                    stats(),
                  ],
                ),
                bottom: TabBar(
                  tabs: tabs,
                  indicatorColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.tab,
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      Share.share(profileUrl);
                    },
                    icon: const Icon(Icons.share),
                  ),
                ],
              ),
              body: const TabBarView(
                children: [
                  AboutSection(),
                  ContactSection(),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Padding hobbies() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: FutureBuilder<String>(
        future: Future.wait([
          _fireStoreService.getUserField('favorite_sport'),
          _fireStoreService.getUserField('level')
        ]).then((results) => results.join(' ')),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show a loading indicator while waiting
          } else if (snapshot.hasError) {
            return Text(
                'Error: ${snapshot.error}'); // Show error message if any
          } else {
            return Text(
              snapshot.data ??
                  'Experties not defined yet', // Use the data if available, or a default message
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
            );
          }
        },
      ),
    );
  }

  Padding profileName() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: FutureBuilder<String>(
        future: _fireStoreService.getUserField('full_name'),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show a loading indicator while waiting
          } else if (snapshot.hasError) {
            return Text(
                'Error: ${snapshot.error}'); // Show error message if any
          } else {
            return Text(
              snapshot.data ??
                  'No name', // Use the data if available, or a default message
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            );
          }
        },
      ),
    );
  }

  int _streak = 0;
  late DateTime _lastLoginDate;
  void _loadUserData() async {
    final FireStoreService fireStoreService = FireStoreService();
    String _username = await fireStoreService.getUserField('username');

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_username)
        .get();
    final userData = userDoc.data() as Map<String, dynamic>;

    // Check if lastLoginDate field exists, if not, create it with current date
    if (!userData.containsKey('lastLoginDate')) {
      // Create lastLoginDate field with current date
      await userDoc.reference.update({'lastLoginDate': Timestamp.now()});
      await userDoc.reference.update({'_streak': 0});

      // Update userData to reflect the change
      userData['lastLoginDate'] = Timestamp.now();
    }

    setState(() {
      _streak = userData['_streak'] ?? 0;
      print(_streak);
      _lastLoginDate = userData['lastLoginDate']?.toDate() ??
          DateTime.now().subtract(const Duration(days: 1));
      print(_lastLoginDate);
      _updateStreak();
    });
  }

  void _updateStreak() async {
    // Calculate the difference in days between last login date and current date
    final today = DateTime.now();
    final differenceInDays = today.difference(_lastLoginDate).inDays;
    print(differenceInDays);

    if (differenceInDays == 1) {
      // If user logs in consecutively, increase streak
      setState(() {
        _streak++;
      });
    } else if (differenceInDays > 1) {
      // If user missed logging in for one or more days, reset streak
      setState(() {
        _streak = 1;
      });
    }

    // Update last login date
    _lastLoginDate = today;

    // Save updated data to Firestore
    final FireStoreService fireStoreService = FireStoreService();
    String _username = await fireStoreService.getUserField('username');
    final userDoc =
        FirebaseFirestore.instance.collection('users').doc(_username);
    await userDoc.update({
      '_streak': _streak,
      'lastLoginDate': Timestamp.fromDate(_lastLoginDate),
    });
  }

  Row stats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        statsColumn("Streak", _streak.toString()),
      ],
    );
  }

  Column statsColumn(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color.fromARGB(255, 28, 50, 172),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ],
    );
  }

  Uint8List? _image;

  void selectImage() async {
    final Uint8List? img = await pickImage(ImageSource.gallery);

    setState(() {
      _image = img;
      saveProfileImage();
    });
  }

  void saveProfileImage() async {
    String username = await _fireStoreService.getUserField('username');
    String resp = await StorageService().saveData(
      username: username,
      datatype: "profilePicture",
      file: _image!,
    );

    // Refresh profile image after saving
    if (resp == "the data was saved successfully") {
      loadProfileImage();
    }
  }

  Container profilePhotos() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
      ),
      width: 105,
      height: 105,
      alignment: Alignment.center,
      child: Stack(
        children: [
          _profileImageUrl != null
              ? CircleAvatar(
                  radius: 64,
                  backgroundImage: NetworkImage(_profileImageUrl!),
                )
              : const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage('assets/images/nopp.jpeg'),
                ),
          Positioned(
            bottom: -10,
            left: 60,
            child: IconButton(
              onPressed: selectImage,
              icon: const Icon(Icons.add_a_photo),
            ),
          )
        ],
      ),
    );
  }
}
