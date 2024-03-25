import 'package:flutter/material.dart';
import 'package:testapp/services/auth/auth_exceptions.dart';
import 'package:testapp/services/auth/auth_service.dart';
import 'package:testapp/services/crud/crud_exceptions.dart';
import 'package:testapp/services/crud2/firestore.dart';
import 'package:testapp/utilities/dialogs/error_dialog.dart';
import 'package:testapp/constants/routes.dart';

class RegisterView extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const RegisterView({Key? key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email = TextEditingController();
  late final TextEditingController _password = TextEditingController();
  late final TextEditingController _username = TextEditingController();
  late DateTime _dob = DateTime.now();
  bool _usernameError = false;

  final FireStoreService myDB = FireStoreService();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dob,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != _dob) {
      setState(() {
        _dob = pickedDate;
      });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Create New Account',
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/images/registerImage.jpg',
                  height: 200,
                  filterQuality: FilterQuality.high,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _username,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Enter your username',
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: Colors.grey[200],
                    filled: true,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    errorText: _usernameError ? 'Username already taken' : null,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.black),
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
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
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
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    'Date of Birth: ${_dob.year}-${_dob.month}-${_dob.day}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final email = _email.text;
                    final password = _password.text;
                    try {
                      await AuthService.firebase().createUser(
                        email: email,
                        password: password,
                      );
                    } on WeakPasswordAuthException {
                      // ignore: use_build_context_synchronously
                      await showErrorDialog(
                        // ignore: use_build_context_synchronously
                        context,
                        'Weak password',
                      );
                    } on EmailAlreadyInUseAuthException {
                      // ignore: use_build_context_synchronously
                      await showErrorDialog(
                        // ignore: use_build_context_synchronously
                        context,
                        'Email is already in use',
                      );
                    } on InvalidEmailAuthException {
                      // ignore: use_build_context_synchronously
                      await showErrorDialog(
                        // ignore: use_build_context_synchronously
                        context,
                        'Invalid Email',
                      );
                    } on GenericAuthException {
                      // ignore: use_build_context_synchronously
                      await showErrorDialog(
                        // ignore: use_build_context_synchronously
                        context,
                        "Registration failed",
                      );
                    } on UsernameAlreadyExistsException {
                      setState(() {
                        _usernameError = true;
                      });
                    }
                    try {
                      await myDB.addUser(_username.text, _email.text, _dob);

                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pushNamed(
                        additionalInfoRoute,
                        arguments: {'username': _username.text},
                      );
                    } on UsernameAlreadyExistsException {
                      setState(() {
                        _usernameError = true;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                  },
                  child: const Text(
                    "Already have an account?",
                    style: TextStyle(color: Colors.lightBlue),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
