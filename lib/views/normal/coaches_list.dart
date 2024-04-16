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
      ),
      body: const CoachList(),
    );
  }
}

class CoachList extends StatelessWidget {
  const CoachList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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

        final coaches = snapshot.data!.docs;

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

                final userProfile =
                    snapshot.data!.data() as Map<String, dynamic>;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(userProfile['url'] ??
                        'https://i.pinimg.com/564x/16/18/20/1618201e616f4a40928c403f222d7562.jpg'),
                  ),
                  title: Text(coachData['full_name'] ?? 'Coach'),
                  subtitle:
                      Text("domain :${coachData['Domain'] ?? 'No domain'}"),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RequiredUserNameCoachHubView(
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
    );
  }
}
