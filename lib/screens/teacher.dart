// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hazri2/face_recognition/camera_detector.dart';
import 'package:hazri2/global/DashButton.dart';
import 'package:hazri2/screens/LoginPage.dart';

import '../face_recognition/capture_attendance.dart';

class Teacher extends StatefulWidget {
  final String uid;
  const Teacher({Key key, @required this.uid}) : super(key: key);

  @override
  State<Teacher> createState() => _TeacherState();
}

class _TeacherState extends State<Teacher> {
  Future<DocumentSnapshot<Map<String, dynamic>>> userData;

  @override
  void initState() {
    super.initState();
    userData = getUserData();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    return FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              'TEACHER',
              style: GoogleFonts.ubuntu(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xff9DD1F1),
            centerTitle: true,
            shadowColor: Colors.blueGrey,
            leading: const Icon(
              Icons.person,
              color: Colors.white,
            ),
            actions: [
              IconButton(
                icon: const FaIcon(FontAwesomeIcons.rightFromBracket, color: Colors.white,),
                onPressed: () {
                  FirebaseAuth.instance.signOut().then((value) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                  }).onError((error, stackTrace) {
                    print("Error");
                  });
                },
              )
            ],
          ),
          body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: userData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  final userData = snapshot.data.data();
                  final userName = userData['name'];
                  return Column(
                    children: [
                      DashWelcome(
                        name: '$userName!',
                        color: const Color(0xff9DD1F1),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 30.0, right: 30.0, top: 20, bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) =>
                                           const CaptureAttendance())));
                              },
                              child: const DashComp(
                                name: "Capture Attendance",
                                icon: Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 60,
                                ),
                                color: Color(0xff9DD1F1),
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: const DashComp(
                                name: "Manual Attendance",
                                icon: Icon(
                                  Icons.person_add_alt_outlined,
                                  color: Colors.white,
                                  size: 60,
                                ),
                                color: Color(0xff9DD1F1),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 30, left: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {},
                              child: const DashComp(
                                name: "View Attendance",
                                icon: Icon(
                                  Icons.remove_red_eye,
                                  color: Colors.white,
                                  size: 60,
                                ),
                                color: Color(0xff9DD1F1),
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: const DashComp(
                                name: "Generate Report",
                                icon: Icon(
                                  Icons.receipt_outlined,
                                  color: Colors.white,
                                  size: 60,
                                ),
                                color: Color(0xff9DD1F1),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  );
                }
              })),
      onWillPop: () async {
        return false;
      },
    );
  }
}
