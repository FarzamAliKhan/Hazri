import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:hazri2/screens/LoginPage.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: ((context) => const LoginPage())));
    });
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white, // Set your desired background color here
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/hazri-logo.png"),
            const SizedBox(height: 10),
            // Adjust the height based on your preference
            const Text(
              'Facial Recognition Based Student Attendance',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 17,
              ),
              textAlign: TextAlign.center, // Align the text to the center
            ),
          ],
        ),
      ),
    );
  }
}

