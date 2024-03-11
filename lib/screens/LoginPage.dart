// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hazri2/global/clipper.dart';
import 'package:hazri2/global/clipper2.dart';
import 'package:hazri2/screens/Teacher/teacher_nav_bar.dart';
import 'package:hazri2/screens/SignUpPage.dart';
import 'package:hazri2/screens/Admin/admin.dart';
import 'package:hazri2/screens/Student/student.dart';
import 'package:hazri2/screens/Teacher/teacher.dart';

import '../global/styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _email = '';
  String _password = '';
  bool _isLoading = false; // Control the visibility of CircularProgressIndicator


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(children: [
              Stack(
                children: [
                  CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, 300),
                    painter: RPSCustomPainter(),
                  ),
                  Positioned(
                    top: 16,
                    right: -5,
                    child: CustomPaint(
                      size: Size(MediaQuery.of(context).size.width, 300),
                      painter: PSCustomPainter(),
                    ),
                  ),
                  Positioned(
                    top: 200,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Welcome to Hazri NED",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 17),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "LOGIN",
                          style: TextStyle(

                              color: AppColors.secondaryColor,
                              fontWeight: FontWeight.w800, fontSize: 26)
                        ),
                      ],
                    ),
                  )
                ],
              ),
              FractionallySizedBox(
                widthFactor: 0.9,
                child: Column(children: [
                  Form(
                    key: _formKey,
                    child: Column(children: [
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Enter Email",
                          prefixIcon: const Icon(Icons.email_outlined),
                          contentPadding: const EdgeInsets.only(top: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 10,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                                color: AppColors.secondaryColor, width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value.isEmpty || !value.contains('@')) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _email = value;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          contentPadding: const EdgeInsets.only(top: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.white70,
                              width: 0.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                                color: AppColors.secondaryColor, width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value.isEmpty || value.length < 6) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _password = value;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      FractionallySizedBox(
                        widthFactor: 1.0,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () async { // Disable the button if isLoading is true
                            const SpinKitFadingCircle(color: AppColors.secondaryColor);
                                setState(() {
                                  _isLoading = true; // Show CircularProgressIndicator
                                });
                            if (_formKey.currentState.validate()) {
                              try {
                                UserCredential userCredential =
                                    await _auth.signInWithEmailAndPassword(
                                        email: _email, password: _password);


                                if (userCredential.user != null) {
                                  String userId = userCredential.user.uid;

                                  DocumentSnapshot userDoc = await _firestore
                                      .collection('users')
                                      .doc(userId)
                                      .get();
                                  if (userDoc.exists) {
                                    UserModel user = UserModel.fromJson(
                                        userDoc.data() as Map<String, dynamic>);
                                    // Navigate to appropriate screen based on role
                                    // For example:
                                    if (user.role == 'Student') {
                                      Get.off(Student(uid: userCredential.user.uid));
                                    } else if (user.role == 'Teacher') {
                                      // navigates to a screen without context and .off does not allow to
                                      // go back to the previous screen
                                      Get.off(TeacherNavMenu(uid: userCredential.user.uid));
                                      // Navigate to TeacherScreen
                                    } else if (user.role == 'Admin') {
                                      Get.off(Admin(uid: userCredential.user.uid));
                                      // Navigate to AdminScreen
                                    }
                                  }
                                }
                              } catch (e) {
                                //Get version of snack-bar
                                Get.snackbar('Error during login','$e', duration: const Duration(seconds: 5));
                                // Handle login error (e.g., show error message)
                              }
                              finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "Log In",
                              style: GoogleFonts.ubuntu(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpPage()));
                        },
                        child: const Text(
                          "Don't have an account?",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondaryColor),
                        ),
                      ),
                    ],
                  )
                ]),
              )
            ]),
          ),
        ),
    );
  }
}

class UserModel {
  final String id;
  final String email;
  final String role;

  UserModel({@required this.id, @required this.email, @required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Student', // Default role if not provided
    );
  }
}
