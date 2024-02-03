import 'package:flutter/material.dart';
import 'package:testapp/constants/routes.dart';
import 'package:testapp/services/auth/auth_service.dart';

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
              await AuthService.firebase().sendEmailVerfication();
            },
            child: const Text("Send email verification"),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logOut();
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
