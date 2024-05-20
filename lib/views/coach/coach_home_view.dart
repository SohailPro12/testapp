import 'package:flutter/material.dart';
import 'package:testapp/enums/menu_actions.dart';
import 'package:testapp/services/auth/auth_service.dart';
import 'package:testapp/constants/routes.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/services/crud2/storage.dart';
import 'package:testapp/views/coach/hub/coach_hub.dart';
import 'package:testapp/views/conversation_view.dart';
import 'package:testapp/services/chat/fitme_ai_view.dart';

class CoachHomeView extends StatelessWidget {
  CoachHomeView({super.key});

  Future<bool> showLogOutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Log out'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  showDeleteAccountDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text('Are you sure you want to delete your account?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  final FireStoreService _fireStoreService = FireStoreService();
  final StorageService _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _fireStoreService.getUserField('full_name'),
        _fireStoreService.getUserField('username'), // Fetching username
      ]),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show a loading indicator while waiting for the future to complete
        } else if (snapshot.hasError) {
          return Text(
              'Error: ${snapshot.error}'); // Show an error message if the future completes with an error
        } else {
          final String fullName = snapshot.data![0] as String;
          final String username = snapshot.data![1] as String;
          return FutureBuilder<String>(
            // Nested FutureBuilder for fetching profile image URL
            future: _storageService.getUrlfield(username, 'url'),
            builder: (context, imageSnapshot) {
              if (imageSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Show a loading indicator while waiting for the future to complete
              } else {
                final String? profileImageUrl = imageSnapshot.data;
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Home'),
                    backgroundColor: const Color.fromARGB(255, 222, 243, 33),
                    actions: [
                      CircleAvatar(
                        // Assuming you have a user profile picture
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl) as ImageProvider
                            : const AssetImage('assets/images/nopp.jpeg'),
                      ),
                      PopupMenuButton<MenuAction>(
                        onSelected: (value) async {
                          switch (value) {
                            case MenuAction.logout:
                              final shouldLogout =
                                  await showLogOutDialog(context);
                              if (shouldLogout) {
                                AuthService.firebase().logOut();
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  loginRoute,
                                  (_) => false,
                                );
                              }
                              break;
                            case MenuAction.deleteAccount:
                              final shouldDeleteAccount =
                                  await showDeleteAccountDialog(context);
                              if (shouldDeleteAccount) {
                                await _fireStoreService.deleteUser(username);
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pushNamedAndRemoveUntil(
                                  loginRoute,
                                  (_) => false,
                                );
                              }
                              break;
                          }
                        },
                        itemBuilder: (context) {
                          return const [
                            PopupMenuItem<MenuAction>(
                              value: MenuAction.logout,
                              child: Text('Log out'),
                            ),
                            PopupMenuItem<MenuAction>(
                              value: MenuAction.deleteAccount,
                              child: Text('Delete Account!'),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Welcome, Coach $fullName!',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 175, 150,
                                  76), // Change the color to green for enthusiasm
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Use individual Expanded widgets with icons
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(coachProfileViewRoute);
                            },
                            icon: const Icon(Icons.person),
                            label: const Text('View Profile'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ConversationListPage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.message),
                            label: const Text('Check Messages'),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const YourHubView(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.hub),
                            label: const Text('Your hub'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FitMeAIView(),
                                  ));
                            },
                            icon: const Icon(Icons.fitness_center),
                            label: const Text('Explore FitMe AI'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}
