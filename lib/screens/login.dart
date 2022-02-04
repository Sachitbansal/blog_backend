import 'package:blog_test/screens/reset.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passVisible = true;
  late String email;
  late String pass;
  final auth = FirebaseAuth.instance;
  bool isLoggedIn = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    Future<void> login() async {
      try {
        await auth.signInWithEmailAndPassword(email: email, password: pass);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Admin(
            ),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are now logged in'),
          ),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed with error code: ${e.code}'),
          ),
        );
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, size.height * .05, 20, 0),
                  child: const Text(
                    'Client Data Management for Real Estate',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue),
                  ),
                ),
                SizedBox(height: size.height * .01),
                const Text(
                  'Existing User ',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  height: size.height * .01,
                ),
                SizedBox(
                  width: size.width * .9,
                  child: Column(
                    children: [
                      TextFormField(
                        cursorColor: Colors.blue[800],
                        decoration: InputDecoration(
                          fillColor: Colors.blue[50],
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 15.0),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(width: 0.8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              width: 0.8,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          hintText: 'ID',
                          labelText: 'Email ID',
                          prefixIcon: Icon(
                            Icons.account_circle,
                            color: Theme.of(context).primaryColor,
                            // size: 30.0,
                          ),
                        ),
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please Enter an Email';
                          }
                          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                              .hasMatch(value)) {
                            return 'Please Enter a Valid Email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: size.height * .02,
                      ),
                      TextFormField(
                        validator: (val) =>
                            val!.length < 6 ? 'Password too short.' : null,
                        obscureText: passVisible,
                        controller: passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        cursorColor: Colors.blue[800],
                        decoration: InputDecoration(
                          fillColor: Colors.blue[50],
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 15.0),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(width: 0.8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              width: 0.8,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          hintText: 'Enter Password',
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              passVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            color: Theme.of(context).primaryColor,
                            onPressed: () {
                              setState(() {
                                passVisible = !passVisible;
                              });
                            },
                          ),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Theme.of(context).primaryColor,
                            // size: 30.0,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ResetPassword(),
                                ),
                              );
                            },
                            child: const Text(
                              'Reset password ?',
                              style: TextStyle(color: Colors.blue),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: TextButton(
                    child: const Text('Login'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          email = emailController.text;
                          pass = passwordController.text;
                          login();
                        });
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: size.width * .05,
                ),
                SizedBox(
                  height: size.height * .05,
                ),
                const Text(
                  'SBSSdigital Automation Solutions © 2021',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const Text(
                  'Version 1.0',
                  style: TextStyle(
                    color: Colors.grey,
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
