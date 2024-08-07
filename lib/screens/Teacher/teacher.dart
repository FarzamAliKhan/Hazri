// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hazri2/global/DashButton.dart';
import 'package:hazri2/screens/DateListScreen.dart';
import 'package:hazri2/screens/LoginPage.dart';
import '../../face_recognition/capture_attendance.dart';
import '../../global/styles.dart';

class Teacher extends StatefulWidget {
  final String uid;
  const Teacher({Key key, @required this.uid}) : super(key: key);

  @override
  State<Teacher> createState() => _TeacherState();
}

class _TeacherState extends State<Teacher> {
  int currentPageIndex = 0;
  Future<DocumentSnapshot<Map<String, dynamic>>> userData;

  @override
  void initState() {
    super.initState();
    userData = getUserData();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserData() async {
    return FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCourseData() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('courses').get();

    return querySnapshot;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
          body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: userData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                   return const SpinKitFadingCircle(color: AppColors.secondaryColor);
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  final userData = snapshot.data.data();
                  final userName = userData['name'];
                  return Column(
                    children: [
                      DashWelcome(
                        name: '$userName!',
                        color:  AppColors.secondaryColor,
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
                                            CaptureAttendance(teacherId: widget.uid))));
                              },
                              child: const DashComp(
                                name: "Capture Attendance",
                                icon: Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 60,
                                ),
                                color:   Color(0xff508AA8),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const DateListScreen(
                                            RoleType: "Edit Attendance")));
                              },
                              child: const DashComp(
                                name: "Manual Attendance",
                                icon: Icon(
                                  Icons.person_add_alt_outlined,
                                  color: Colors.white,
                                  size: 60,
                                ),
                                color:   Color(0xff508AA8),
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
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const DateListScreen(
                                                RoleType: "View Attendance")));
                              },
                              
                              child: const DashComp(
                                name: "View Attendance",
                                icon: Icon(
                                  Icons.remove_red_eye,
                                  color: Colors.white,
                                  size: 60,
                                ),
                                color: Color(0xff508AA8),
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
                                color: Color(0xff508AA8),
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
