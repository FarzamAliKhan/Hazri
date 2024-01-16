// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hazri2/face_recognition/view_label.dart';
import 'package:hazri2/global/DashButton.dart';
import 'package:hazri2/screens/AttendanceScreen.dart';
import 'package:hazri2/screens/LoginPage.dart';

import '../face_recognition/capture_attendance.dart';
import 'package:hazri2/face_recognition/add_user.dart';

import 'DateListScreen.dart';


class Admin extends StatefulWidget {
  final String uid;
  const Admin({Key key, @required this.uid}) : super(key: key);

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
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
          appBar: AppBar(
            title: Text(
              'ADMIN',
              style: GoogleFonts.ubuntu(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xff508AA8),
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
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        DashWelcome(
                          name: '$userName!',
                          color: const Color(0xff508AA8),
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
                                              const AddUser())));
                                },
                                child: const DashComp(
                                  name: "Add User",
                                  icon: Icon(
                                    Icons.person_add_alt,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                  color: Color(0xff508AA8),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: ((context) => ViewLabel())));
                                },
                                child: const DashComp(
                                  name: "Manage User",
                                  icon: Icon(
                                    Icons.person_2_outlined,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                  color: Color(0xff508AA8),
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
                                          builder: ((context) =>
                                              const DateListScreen(RoleType: "Edit Attendance",))));
                                },
                                child: const DashComp(
                                  name: "Edit Attendance",
                                  icon: Icon(
                                    Icons.edit_document,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                  color: Color(0xff508AA8),
                                ),
                              ),
                              InkWell(
                                // onTap: () async {
                                //   // Fetch courseData inside the onTap callback
                                //   QuerySnapshot<Map<String, dynamic>>
                                //       courseDataSnapshot =
                                //       await getCourseData();

                                //   // Extract the courseCode from the first document in the query result
                                //   String courseCode =
                                //       courseDataSnapshot.docs.isNotEmpty
                                //           ? courseDataSnapshot.docs[0]
                                //               .data()['courseCode']
                                //           : '';

                                //   // ignore: use_build_context_synchronously
                                //   Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => ViewAttendance(
                                //             courseCode: courseCode,
                                //             sessionDocumentId:
                                //                 "1fb7ph6V9VnA7jMBVzyH")),
                                //   );
                                // },
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: ((context) => DateListScreen(RoleType: "View Attendance",))));
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
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30, left: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {},
                                child: const DashComp(
                                  name: "Notices",
                                  icon: Icon(
                                    Icons.notifications_active_outlined,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                                  color: Color(0xff508AA8),
                                ),
                              ),
                              InkWell(
                                onTap: () {},
                                child: const DashComp(
                                  name: "Monitor Diagnostics",
                                  icon: Icon(
                                    Icons.monitor_heart_outlined,
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
                    ),
                  );
                }
              })),
      onWillPop: () async {
        return false;
      },
    );
  }
}
