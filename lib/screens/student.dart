// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hazri2/global/dashButton.dart';
import 'package:hazri2/screens/LoginPage.dart';
import 'package:hazri2/screens/studentAttendance.dart';

class Student extends StatefulWidget {
  final String uid;
  const Student({Key key, @required this.uid}) : super(key: key);

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
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
              title:  Text('STUDENT', style: GoogleFonts.ubuntu(color: Colors.white, fontWeight: FontWeight.bold),),
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xff508AA8),
              centerTitle: true,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              // elevation: 5,
              shadowColor: Colors.blueGrey,
              leading: const Icon(Icons.person, color: Colors.white,),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout_outlined, color: Colors.white,),
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
                  }
                  else if (snapshot.hasError){
                    return Text("Error: ${snapshot.error}");
                  }
                  else{
                  final userData = snapshot.data.data();
                  final userName = userData['name'];
                  return Column(
                    children: [
                      DashWelcome(name: '$userName!', color: Color(0xff508AA8),),
                      const SizedBox(
                        height: 10,
                      ),
                       Padding(
                        padding: const EdgeInsets.only(left:30.0, right: 30.0, top: 20, bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            StudentAttendance(studentName: userName,)));
                              },
                              child: const DashComp(
                                name: "View Attendance",
                                icon: Icon(Icons.remove_red_eye, color: Colors.white,size: 60,),
                                color: Color(0xff508AA8),
                              ),
                            ),
                            InkWell(
                              onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            StudentAttendance(studentName: userName, roleType: "Report Generate",)));
                              },
                              child: const DashComp(
                                name: "Generate Report",
                                icon: Icon(Icons.receipt_outlined, color: Colors.white, size: 60,),
                                color: Color(0xff508AA8),
                              ),
                            )
                          ],
                        ),
                      ),
                      
                    ],
                  );
                  }
                })),
        onWillPop: () async {
          return false;
        });
  }
}
