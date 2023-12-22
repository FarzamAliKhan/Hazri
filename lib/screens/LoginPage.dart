import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hazri2/global/clipper.dart';
import 'package:hazri2/global/clipper2.dart';
import 'package:hazri2/screens/SignUpPage.dart';
import 'package:hazri2/screens/admin.dart';
import 'package:hazri2/screens/student.dart';
import 'package:hazri2/screens/teacher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _email = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
                const Positioned(
                  top: 220,
                  left: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "LOGIN",
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 26),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Please sign in to continue",
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 17),
                      )
                    ],
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 28),
              child: Column(children: [
                const SizedBox(
                  height: 25,
                ),
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
                            color: Colors.grey,
                            width: 5.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Color(0xfffca148), width: 3.0),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
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
                            color: Colors.grey,
                            width: 5.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                              color: Color(0xfffca148), width: 3.0),
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty || value.length < 6) {
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
                      height: 25,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            UserCredential userCredential =
                                await _auth.signInWithEmailAndPassword(
                                    email: _email, password: _password);
      
                            if (userCredential.user != null) {
                              String userId = userCredential.user!.uid;
      
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
                               
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Student()));
                                } else if (user.role == 'Teacher') {
                                 
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const Teacher()));
                                  // Navigate to TeacherScreen
                                } else if (user.role == 'Admin') {
                               
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Admin()));
                                  // Navigate to AdminScreen
                                }
                              }
                            }
                          } catch (e) {
                            print('Error during login: $e');
                            // Handle login error (e.g., show error message)
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xfff7b858),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          "Log In",
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 140,
                    ),
                  ]),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpPage()));
                      },
                      child: const Text(
                        "SIGN UP",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xfffca148)),
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

  UserModel({required this.id, required this.email, required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Student', // Default role if not provided
    );
  }
}
