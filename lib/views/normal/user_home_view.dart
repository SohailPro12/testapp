import 'package:flutter/material.dart';
import 'package:testapp/enums/menu_actions.dart';
import 'package:testapp/services/auth/auth_service.dart';
import 'package:testapp/constants/routes.dart';
import 'package:testapp/services/chat/fitme_ai_view.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/services/crud2/storage.dart';
import 'package:testapp/views/conversation_view.dart';
import 'package:testapp/views/normal/coaches_list.dart';
import 'package:testapp/views/normal/routinesssss/combind.dart';
import 'package:testapp/views/normal/profile/user_profile_view.dart';

class UserHomeView extends StatelessWidget {
  UserHomeView({super.key});

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

  Future<bool> showDeleteAccountDialog(BuildContext context) {
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
          return const Center(
            child: CircularProgressIndicator(
                color: Color.fromARGB(255, 139, 69, 19)),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          final String fullName = snapshot.data![0] as String;
          final String username = snapshot.data![1] as String;
          return FutureBuilder<String>(
            future: _storageService.getUrlfield(username, 'url'),
            builder: (context, imageSnapshot) {
              if (imageSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 139, 69, 19)),
                );
              } else {
                final String? profileImageUrl = imageSnapshot.data;
                return Scaffold(
                  appBar: AppBar(
                    title: Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/icon/icon.png',
                            height: 30,
                            width: 30,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text('Home'),
                      ],
                    ),
                    flexibleSpace: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 165, 42, 42),
                            Color.fromARGB(255, 210, 105, 30),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    actions: [
                      CircleAvatar(
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
                            'Welcome $fullName!',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 139, 69, 19),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UserProfileView(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.person,
                              size: 45,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'My profile',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 165, 42, 42),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              textStyle: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CombinedPage(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.create,
                              size: 45,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Create My Routine',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 165, 42, 42),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              textStyle: const TextStyle(color: Colors.white),
                            ),
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
                            icon: const Icon(Icons.message,
                                size: 45, color: Colors.white),
                            label: const Text(
                              'Check Messages',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 165, 42, 42),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              textStyle: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CoachesListView(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.message,
                              size: 45,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Coaches',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 165, 42, 42),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              textStyle: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FitMeAIView(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.fitness_center,
                              size: 45,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Explore FitMe Ai',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 165, 42, 42),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              textStyle: const TextStyle(color: Colors.white),
                            ),
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
