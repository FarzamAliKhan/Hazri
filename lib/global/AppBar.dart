import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hazri2/global/styles.dart';

import '../screens/LoginPage.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  //final List<Widget> actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    //this.actions = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
            toolbarHeight: 35,
            title: Container( padding: const EdgeInsets.fromLTRB(5,15,0,0),
              child: Text(
                title, style:
                GoogleFonts.ubuntu(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            automaticallyImplyLeading: false,
            backgroundColor:  AppColors.secondaryColor,
            actions: [

            ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}