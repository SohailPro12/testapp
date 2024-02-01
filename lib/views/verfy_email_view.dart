import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:testapp/constants/routes.dart';

class VerifyEmailview extends StatefulWidget {
  const VerifyEmailview({super.key});

  @override
  State<VerifyEmailview> createState() => _VerifyEmailviewState();
}

class _VerifyEmailviewState extends State<VerifyEmailview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Email verification"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          const Text(
              "We have sent you an email verification. Please open it to verify your account"),
          const Text(
              "If you have not received a verification email yet! please press the button below!"),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              await user?.sendEmailVerification();
            },
            child: const Text("Send email verification"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                (route) => false,
              );
            },
            child: const Text("Restart"),
          )
        ],
      ),
    );
  }
}
