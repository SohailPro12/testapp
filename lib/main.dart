import 'package:flutter/material.dart';
//import 'package:path/path.dart';
import 'package:testapp/constants/routes.dart';
import 'package:testapp/services/auth/auth_service.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/views/additionalinfo_view.dart';
import 'package:testapp/views/coach/coach_additional_info.dart';
import 'package:testapp/views/coach/coach_home_view.dart';
import 'package:testapp/views/coach/profile/coach_profile_view.dart';
import 'package:testapp/views/login_view.dart';
import 'package:testapp/views/normal/ma_routine.dart';
import 'package:testapp/views/normal/profile/user_profile_view.dart';
import 'package:testapp/views/normal/user_home_view.dart';
import 'package:testapp/views/notes/create_update_note_view.dart';
import 'package:testapp/views/notes/notes_view.dart';
import 'package:testapp/views/register_view.dart';
import 'package:testapp/views/verfy_email_view.dart';

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // ensure that the button is initialized
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
          notesRoute: (context) => const NotesView(),
          verifyemailRoute: (context) => const VerifyEmailview(),
          additionalInfoRoute: (context) => const AdditionalInfo(),
          coachaAdditionalInfoRoute: (context) => const CoachaAdditionalInfo(
                fullName: '',
              ),
          createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
          iAmANormalUserRoute: (context) => UserHomeView(),
          coachProfileViewRoute: (context) => const CoachProfileView(),
          iAmACoachRoute: (context) => CoachHomeView(),
          routineuser: (context) => const WeeklyPlanner(),
          userProfileViewRoute: (context) => const UserProfileView(),
        }),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            final FireStoreService fireStoreService = FireStoreService();
            if (user != null) {
              if (user.isEmailVerified) {
                return FutureBuilder<Map<String, dynamic>>(
                    future: fireStoreService.getUserData(user.email),
                    builder: (context, userDataSnapshot) {
                      try {
                        if (userDataSnapshot.connectionState ==
                            ConnectionState.done) {
                          final userType =
                              userDataSnapshot.data?['type'] as String?;
                          if (userType == 'coach') {
                            return CoachHomeView();
                          } else if (userType == 'normal') {
                            return UserHomeView();
                          }
                        }
                      } catch (_) {
                        throw Exception("unknown user");
                      }
                      return const CircularProgressIndicator();
                    });
              } else {
                return const VerifyEmailview();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
