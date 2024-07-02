import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testapp/views/normal/hub_search/coach_hub.dart';

class CoachesListView extends StatelessWidget {
  const CoachesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coaches'),
        backgroundColor: Colors.red,
      ),
      body: const CoachList(),
    );
  }
}

class CoachList extends StatefulWidget {
  const CoachList({super.key});

  @override
  _CoachListState createState() => _CoachListState();
}

class _CoachListState extends State<CoachList> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search by name',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('type', isEqualTo: 'coach')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final coaches = snapshot.data!.docs.where((doc) {
                final coachData = doc.data() as Map<String, dynamic>;
                final fullName = coachData['Domain']?.toLowerCase() ?? '';
                return fullName.contains(searchQuery);
              }).toList();

              if (coaches.isEmpty) {
                return const Center(
                  child: Text('No coaches found.'),
                );
              }

              return ListView.builder(
                itemCount: coaches.length,
                itemBuilder: (context, index) {
                  final coach = coaches[index];
                  final coachData = coach.data() as Map<String, dynamic>;

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('userProfile')
                        .doc(coachData['username'])
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(
                          title: Text('Loading...'),
                        );
                      }

                      if (snapshot.hasError) {
                        return ListTile(
                          title: Text('Error: ${snapshot.error}'),
                        );
                      }

                      final userProfile =
                          snapshot.data!.data() as Map<String, dynamic>;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            userProfile['url'] ??
                                'https://i.pinimg.com/564x/16/18/20/1618201e616f4a40928c403f222d7562.jpg',
                          ),
                        ),
                        title: Text(coachData['full_name'] ?? 'Coach'),
                        subtitle: Text(
                            "domain :${coachData['Domain'] ?? 'No domain'}"),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  RequiredUserNameCoachHubView(
                                username: coachData['username'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
