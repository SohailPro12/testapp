import 'package:flutter/material.dart';
import 'package:testapp/constants/routes.dart';
import 'package:testapp/services/auth/auth_exceptions.dart';
import 'package:testapp/services/auth/auth_service.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/utilities/dialogs/error_dialog.dart';
import 'package:testapp/views/coach/coach_home_view.dart';
import 'package:testapp/views/normal/user_home_view.dart';
import 'package:testapp/views/password_reset_view.dart'; // Import the password reset view

class LoginView extends StatefulWidget {
  const LoginView({Key? key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  final FireStoreService _fireStoreService = FireStoreService();
  bool _isPasswordVisible = false;

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Welcome! Login to your account',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/loginImage.jpg',
                  height: 200,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: Colors.grey[200],
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _password,
                  obscureText: !_isPasswordVisible,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: Colors.grey[200],
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      child: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;

                      try {
                        await AuthService.firebase().logIn(
                          email: email,
                          password: password,
                        );
                        final user = AuthService.firebase().currentUser;
                        if (user?.isEmailVerified ?? false) {
                          final userData =
                              await _fireStoreService.getUserData(email);
                          final userType = userData['type'] as String;
                          if (userType == 'coach') {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CoachHomeView(),
                                ));
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserHomeView(),
                              ),
                            );
                          }
                        } else {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            verifyemailRoute,
                            (route) => false,
                          );
                        }
                      } on UserNotFoundAuthException {
                        await showErrorDialog(
                          context,
                          'Invalid Name or Password! Please enter the right information.',
                        );
                      } on WrongPasswordAuthException {
                        await showErrorDialog(
                          context,
                          'Please complete all the required information.',
                        );
                      } on GenericAuthException {
                        await showErrorDialog(
                          context,
                          "Authentication failed",
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      registerRoute,
                      (route) => false,
                    );
                  },
                  child: const Text(
                    "Not registered yet? Please register here!",
                    style: TextStyle(color: Colors.lightBlue),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PasswordResetView(),
                    ));
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.lightBlue),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
