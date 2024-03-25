import 'package:flutter/material.dart';
import 'package:testapp/views/coach/profile/about.dart';
import 'package:testapp/views/coach/profile/contact.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

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
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Text(
        "Traveller - Dreamer - Fighter",
        style: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Padding profileName() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Text(
        "Asep Saputra",
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
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

  Container profilePhotos() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
      ),
      width: 105,
      height: 105,
      alignment: Alignment.center,
      child: const CircleAvatar(
        radius: 50,
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(
          "https://picsum.photos/300/300",
        ),
      ),
    );
  }
}
