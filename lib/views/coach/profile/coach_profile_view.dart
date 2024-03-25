import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/views/coach/profile/about.dart';
import 'package:testapp/views/coach/profile/contact.dart';
import 'package:testapp/views/coach/profile/utils.dart';

class CoachProfileView extends StatefulWidget {
  const CoachProfileView({super.key});

  @override
  State<CoachProfileView> createState() => _CoachProfileViewState();
}

final FireStoreService _fireStoreService = FireStoreService();

class _CoachProfileViewState extends State<CoachProfileView> {
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
  Widget build(BuildContext context) {
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

  Padding hobbies() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: FutureBuilder<String>(
        future: Future.wait([
          _fireStoreService.getUserField('Domain'),
          _fireStoreService.getUserField('type')
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

  Row stats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        statsColumn("Photos", "160"),
        statsColumn("Followers", "1657"),
        statsColumn("Following", "9"),
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
    if (img != null) {
      setState(() {
        _image = img;
      });
      final username = await _fireStoreService.getUserField('full_name');
      try {
        await _fireStoreService.updateUserPhoto(
            username, img); // Update user's profile photo
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated successfully')),
        );
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile photo: $e')),
        );
      }
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
      child: Stack(children: [
        _image != null
            ? CircleAvatar(
                radius: 64,
                backgroundImage: MemoryImage(_image!),
              )
            : const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.transparent,
                backgroundImage: NetworkImage(
                  "https://picsum.photos/300/300",
                ),
              ),
        Positioned(
          bottom: -10,
          left: 60,
          child: IconButton(
            onPressed: selectImage,
            icon: const Icon(Icons.add_a_photo),
          ),
        )
      ]),
    );
  }
}
