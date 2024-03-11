import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hazri2/global/styles.dart';
import 'package:hazri2/screens/UserProfileScreen.dart';

import '../global/AppBar.dart';
import 'LoginPage.dart';

class UserProfileScreen extends StatefulWidget {
  final String uid;

  UserProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

Future<DocumentSnapshot<Map<String, dynamic>>> getUserData(String uid) async {
  return FirebaseFirestore.instance.collection('users').doc(uid).get();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> userData;

  @override
  void initState() {
    super.initState();
    userData = getUserData(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'User Profile'),
      body: SafeArea(
        child: FutureBuilder(
          future: userData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SpinKitFadingCircle(color: AppColors.secondaryColor);
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else {
              final userData = snapshot.data?.data();
              final userName = userData!['name'];
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipOval(
                          child: Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(240),
                              color: AppColors.secondaryColor,
                            ),
                            child: Image.asset(
                              'assets/user-profile.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text('$userName ',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 8.0,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                 FirebaseAuth.instance.signOut().then((value) {
                                  Get.to(const LoginPage());
                                }).onError((error, stackTrace) {
                                  Get.snackbar('Error', '$error');
                                });
                               },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tertiaryColor,
                                foregroundColor: AppColors.textColor
                               ),
                              child: const Text(
                                  'Logout', style: TextStyle(
                                   color: AppColors.textColor,
                                   fontSize: 20
                              ),)
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
