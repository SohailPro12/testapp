import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testapp/constants/routes.dart';
import 'package:testapp/firebase_options.dart';
import 'package:testapp/intro_screen.dart';
import 'package:testapp/services/auth/auth_service.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/views/additionalinfo_view.dart';
import 'package:testapp/views/coach/coach_additional_info.dart';
import 'package:testapp/views/coach/coach_home_view.dart';
import 'package:testapp/views/coach/profile/coach_profile_view.dart';
import 'package:testapp/views/login_view.dart';
import 'package:testapp/views/normal/profile/user_profile_view.dart';
import 'package:testapp/views/normal/user_home_view.dart';
import 'package:testapp/views/register_view.dart';
import 'package:testapp/views/verfy_email_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        verifyemailRoute: (context) => const VerifyEmailview(),
        additionalInfoRoute: (context) => const AdditionalInfo(),
        coachaAdditionalInfoRoute: (context) =>
            const CoachaAdditionalInfo(fullName: ''),
        iAmANormalUserRoute: (context) => UserHomeView(),
        coachProfileViewRoute: (context) => const CoachProfileView(),
        iAmACoachRoute: (context) => CoachHomeView(),
        userProfileViewRoute: (context) => const UserProfileView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<bool> _checkIfFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('isFirstRun') ?? true;
    if (isFirstRun) {
      prefs.setBool('isFirstRun', false);
    }
    return isFirstRun;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkIfFirstRun(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.data == true) {
          return IntroScreen();
        } else {
          return FutureBuilder(
            future: AuthService.firebase().initialize(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final user = AuthService.firebase().currentUser;
                if (user != null) {
                  if (user.isEmailVerified) {
                    return FutureBuilder<Map<String, dynamic>>(
                      future: FireStoreService().getUserData(user.email),
                      builder: (context, userDataSnapshot) {
                        if (userDataSnapshot.connectionState ==
                            ConnectionState.done) {
                          final userType =
                              userDataSnapshot.data?['type'] as String?;
                          if (userType == 'coach') {
                            return CoachHomeView();
                          } else if (userType == 'normal') {
                            return UserHomeView();
                          } else {
                            return const LoginView();
                          }
                        } else {
                          return const CircularProgressIndicator();
                        }
                      },
                    );
                  } else {
                    return const VerifyEmailview();
                  }
                } else {
                  return const LoginView();
                }
              } else {
                return const CircularProgressIndicator();
              }
            },
          );
        }
      },
    );
  }
}
