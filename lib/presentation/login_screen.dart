import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_culture/presentation/Info.dart';
import 'package:urban_culture/utils/helper_functions.dart';

class UserLoginPage extends StatefulWidget {
  @override
  _UserLoginPageState createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _errorMessage = '';

  Future<void> loginUser() async {
    HelperFunctions.showLoading(context);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await _handleUserData(userCredential.user);
    } on FirebaseAuthException catch (e) {
      HelperFunctions.hideLoading(context);

      setState(() {
        _errorMessage = e.message ?? 'An error occurred.';
      });
    }
  }

  Future<void> createUser() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await _handleUserData(userCredential.user);
    } on FirebaseAuthException catch (e) {
      HelperFunctions.hideLoading(context);
      setState(() {
        _errorMessage = e.message ?? 'An error occurred.';
      });
    }
  }

  Future<void> _handleUserData(User? user) async {
    if (user == null) {
      HelperFunctions.hideLoading(context);
      return;
    }

    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    DocumentSnapshot userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      await userDoc.update({
        'lastLogin': Timestamp.now(),
        'streakCount': FieldValue.increment(1), // Increment streakCount
      });
    } else {
      await userDoc.set({
        'lastLogin': Timestamp.now(),
        'streakCount': 0, // Initial streak count
      });
    }

    print("User id : ${userSnapshot.id}");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
    prefs.setString('userId', userSnapshot.id);
    HelperFunctions.hideLoading(context);

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
        (value) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('User Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/login_animation.gif', width: 200),
              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Error Message Display
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                ),

              // Login Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    loginUser();
                  }
                },
                child: Text('Login'),
              ),
              SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    HelperFunctions.showLoading(context);
                    createUser();
                  }
                },
                child: Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
