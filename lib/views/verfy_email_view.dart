import 'package:flutter/material.dart';
import 'package:testapp/constants/routes.dart';
import 'package:testapp/services/auth/auth_service.dart';

class VerifyEmailview extends StatefulWidget {
  const VerifyEmailview({Key? key});

  @override
  State<VerifyEmailview> createState() => _VerifyEmailviewState();
}

class _VerifyEmailviewState extends State<VerifyEmailview> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Email Verification"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "We have sent you an email verification.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18), // Increased font size
              ),
              const SizedBox(height: 10),
              const Text(
                "Please open it to verify your account.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18), // Increased font size
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await AuthService.firebase().sendEmailVerfication();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Blue button color
                ),
                child: const Text("Resend Email Verification"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await AuthService.firebase().logOut();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Red button color
                ),
                child: const Text("Restart"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
