import 'package:flutter/material.dart';
import 'package:testapp/constants/routes.dart';
import 'package:testapp/services/auth/auth_exceptions.dart';
import 'package:testapp/services/auth/auth_service.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/utilities/dialogs/error_dialog.dart';
import 'package:testapp/views/coach/coach_home_view.dart';
import 'package:testapp/views/normal/user_home_view.dart';
//import 'package:testapp/views/normal/user_home_view.dart';

class LoginView extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
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
      backgroundColor: Colors.white, // White background color
      appBar: AppBar(
        title: const Text(
          'Welcome! Login to your account', // Updated title
          style: TextStyle(
            color: Colors.blue, // Blue header color
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent, // Transparent app bar
        elevation: 0, // No shadow
        centerTitle: true, // Center align the title
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/loginImage.jpg', // Replace 'your_image.png' with your image asset path
                  height: 200,
                  filterQuality: FilterQuality.high, // Adjust height as needed
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle:
                        const TextStyle(color: Colors.grey), // Grey hint color
                    fillColor: Colors.grey[200], // Light grey background
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none, // No border
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
                    hintStyle:
                        const TextStyle(color: Colors.grey), // Grey hint color
                    fillColor: Colors.grey[200], // Light grey background
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none, // No border
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
                  // Wrapping login button in SizedBox with specified width
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
                          // Save FCM token
                          /* await saveFcmToken(userData['username']); */
                          if (userType == 'coach') {
                            // ignore: use_build_context_synchronously
                            Navigator.pushReplacement(
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CoachHomeView(),
                                ));
                          } else {
                            // ignore: use_build_context_synchronously
                            Navigator.pushReplacement(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserHomeView(),
                              ),
                            );
                          }
                        } else {
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            verifyemailRoute,
                            (route) => false,
                          );
                        }
                      } on UserNotFoundAuthException {
                        // ignore: use_build_context_synchronously
                        await showErrorDialog(
                          // ignore: use_build_context_synchronously
                          context,
                          'Invalid Name or Password! Please enter the right information.',
                        );
                      } on WrongPasswordAuthException {
                        // ignore: use_build_context_synchronously
                        await showErrorDialog(
                          // ignore: use_build_context_synchronously
                          context,
                          'Please complete all the required information.',
                        );
                      } on GenericAuthException {
                        // ignore: use_build_context_synchronously
                        await showErrorDialog(
                          // ignore: use_build_context_synchronously
                          context,
                          "Authentication failed",
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Blue button color
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
                    style: TextStyle(
                        color: Colors.lightBlue), // Light blue text color
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
