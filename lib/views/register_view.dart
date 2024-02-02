import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testapp/utilities/show_error_dialog.dart';
import 'package:testapp/constants/routes.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController
      _email; //late means that we well asign a value later
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration:
                const InputDecoration(hintText: 'Please here enter your email'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
                hintText: 'Please here enter your password'),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: email, password: password);
                final user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
                // ignore: use_build_context_synchronously
                Navigator.of(context).pushNamed(verifyemailRoute);
              } on FirebaseAuthException catch (e) {
                if (e.code == 'weak-password') {
                  // ignore: use_build_context_synchronously
                  await showErrorDialog(
                    context,
                    'Weak password',
                  );
                } else if (e.code == 'email-already-in-use') {
                  // ignore: use_build_context_synchronously
                  await showErrorDialog(
                    context,
                    'Email is already in use',
                  );
                } else if (e.code == 'invalid-email') {
                  // ignore: use_build_context_synchronously
                  await showErrorDialog(
                    context,
                    'Invalid Email',
                  );
                } else if (e.code == 'network-request-failed') {
                  // ignore: use_build_context_synchronously
                  await showErrorDialog(
                    context,
                    'Please check your network',
                  );
                } else {
                  // ignore: use_build_context_synchronously
                  await showErrorDialog(
                    context,
                    'Error: ${e.code}',
                  );
                }
              } catch (e) {
                // ignore: use_build_context_synchronously
                await showErrorDialog(
                  context,
                  e.toString(),
                );
              }
            },
            child: const Text('Registre'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: const Text("You already have an account?"),
          )
        ],
      ),
    );
  }
}
