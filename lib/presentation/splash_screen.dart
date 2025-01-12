import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_culture/presentation/Info.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    fetchAndSetUserId();
    Timer(Duration(seconds: 3), () {
      _checkLoginStatus();
    });
  }

  fetchAndSetUserId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    MyHomePage.userId = pref.getString('userId') ?? "";
  }

  Future<void> _checkLoginStatus() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool? isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } else {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserLoginPage()),
        );
      }
    } else {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserLoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2E8EB),
      body: Center(
        child: SizedBox(
            height: 100, width: 100, child: Image.asset('assets/app_icon.png')),
      ),
    );
  }
}
