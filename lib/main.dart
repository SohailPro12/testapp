import 'package:flutter/material.dart';
import 'package:testapp/constants/routes.dart';
import 'package:testapp/services/auth/auth_service.dart';
import 'package:testapp/views/additionalinfo_view.dart';
import 'package:testapp/views/coach/coach_additional_info.dart';
import 'package:testapp/views/login_view.dart';
import 'package:testapp/views/notes/new_note_view.dart';
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
        newNoteRoute: (context) => const NewNoteView(),
      },
    ),
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
            if (user != null) {
              if (user.isEmailVerified) {
                return const NotesView();
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
