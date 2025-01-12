import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urban_culture/presentation/routines_page.dart';
import 'package:urban_culture/presentation/streaks_page.dart';

import '../data/model/skincare_model.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  static String userId = "";

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = 0;

  @override
  void initState() {
    fetchAndSetUserId();
    super.initState();
  }

  fetchAndSetUserId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    MyHomePage.userId = pref.getString('userId') ?? "";
  }

  static final List<Widget> _pages = <Widget>[
    RoutinePage(),
    StreaksPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: currentIndex == 0
            ? const Text(
                "Daily skincare",
                style: TextStyle(fontWeight: FontWeight.w800),
              )
            : const Text("Streaks",
                style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      bottomNavigationBar: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Divider(
              color: Colors.black12,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 125),
            child: Theme(
              data: ThemeData(
                  splashColor: Colors.transparent,
                  colorScheme:
                      ColorScheme.fromSeed(seedColor: const Color(0xff964F66))),
              child: BottomNavigationBar(
                  currentIndex: currentIndex,
                  backgroundColor: Colors.transparent,
                  onTap: (value) {
                    setState(() {
                      currentIndex = value;
                    });
                  },
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(
                        icon: ImageIcon(AssetImage("assets/img.png")),
                        label: "Routine"),
                    BottomNavigationBarItem(
                        icon: ImageIcon(AssetImage("assets/img_1.png")),
                        label: "Streaks"),
                  ]),
            ),
          ),
        ],
      ),
      body: Center(
        child: _pages[currentIndex],
      ),
    );
  }
}
