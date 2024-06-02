import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/views/normal/coachsearchprofile/about.dart';
import 'package:testapp/views/normal/coachsearchprofile/contact.dart';

class RequiredCoachnameProfileView extends StatefulWidget {
  final String username;

  const RequiredCoachnameProfileView({super.key, required this.username});

  @override
  State<RequiredCoachnameProfileView> createState() =>
      _RequiredCoachnameProfileViewState();
}

final FireStoreService _fireStoreService = FireStoreService();

class _RequiredCoachnameProfileViewState
    extends State<RequiredCoachnameProfileView> {
  late String _username;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _username = widget.username;
    loadProfileImage();
  }

  void loadProfileImage() async {
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: Future.value(_username),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          String profileUrl = 'https://fitme.com/profile/$_username';

          return DefaultTabController(
            length: 2,
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
                bottom: const TabBar(
                  tabs: [
                    Tab(text: "About", icon: Icon(Icons.account_box)),
                    Tab(text: "Contact", icon: Icon(Icons.contact_page)),
                  ],
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
                  AboutSection(username: _username),
                  ContactSection(username: _username),
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
        future: _fireStoreService.getUserFieldByUsername('Domain', _username),
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
        future:
            _fireStoreService.getUserFieldByUsername('full_name', _username),
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

  Row stats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        statsColumn("Photos", "160"),
        statsColumn("Followers", "1657"),
        statsColumn("Customer", "9"),
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
