import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart'; // Import the share_plus package
import 'package:testapp/services/crud/crud_exceptions.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/views/coach/profile/utils.dart';
import 'package:testapp/views/coach/usersearchprofile/about.dart';
import 'package:testapp/views/coach/usersearchprofile/contact.dart';

class RequiredUsernameProfileView extends StatefulWidget {
  final String username; // Add username as a parameter

  // ignore: use_super_parameters
  const RequiredUsernameProfileView({Key? key, required this.username})
      : super(key: key);

  @override
  State<RequiredUsernameProfileView> createState() =>
      _RequiredUsernameProfileViewState();
}

class _RequiredUsernameProfileViewState
    extends State<RequiredUsernameProfileView> {
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
    _loadUserMetrics();
  }

  Row stats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        statsColumn("Weight", w),
        statsColumn("Height", h),
      ],
    );
  }

  var w = "";
  var h = "";

  void _loadUserMetrics() async {
    final fireStoreService = FireStoreService();

    final weight = await fireStoreService.getUserFieldByUsername(
        'weight', widget.username);
    final height = await fireStoreService.getUserFieldByUsername(
        'height', widget.username);
    setState(() {
      // Initialize the controllers with the retrieved values
      w = weight;
      h = height;
    });
    print(w + h);
  }

  String? _profileImageUrl;

  void loadProfileImage() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('userProfile')
        .where('username', isEqualTo: widget.username) // Use widget.username
        .where('datatype', isEqualTo: 'profilePicture')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _profileImageUrl = querySnapshot.docs.first.get('url');
      });
    }
  }

  Future<String> getUserFieldByUsername(
      String username, String fieldName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final userData = querySnapshot.docs.first.data();
      final fieldValue = (userData)[fieldName]?.toString() ?? '';
      return fieldValue;
    } else {
      throw UserNotFoundException();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: getUserFieldByUsername(widget.username, 'username'),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          String username = snapshot.data ?? '';
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
              body: TabBarView(
                children: [
                  AboutSection(username: username),
                  ContactSection(
                    username: username,
                  ),
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
        future: getUserFieldByUsername(widget.username, 'favorite_sport'),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Text(
              snapshot.data ?? 'Experties not defined yet',
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
        future: getUserFieldByUsername(widget.username, 'full_name'),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Text(
              snapshot.data ?? 'No name',
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
    });
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
        ],
      ),
    );
  }
}
