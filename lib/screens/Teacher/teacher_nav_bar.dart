import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hazri2/face_recognition/capture_attendance.dart';
import 'package:hazri2/global/styles.dart';
import 'package:hazri2/screens/AttendanceScreen.dart';
import 'package:hazri2/screens/DateListScreen.dart';
import 'package:hazri2/screens/LoginPage.dart';

import 'teacher.dart';

class TeacherNavMenu extends StatelessWidget {
  final String uid;
  const TeacherNavMenu({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    //initializing controller and passing uid for specific users
    final controller = Get.put(NavigationController(uid: uid));
    return Scaffold(
      //wrapping with Obx which acts as the observer whenever selectedIndex changes its state will be reflected here
      bottomNavigationBar: Obx(
        () => NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          animationDuration: const Duration(milliseconds: 650),
          elevation: 0,
          height: 65,
          selectedIndex: controller.selectedIndex.value,
          // onDestinationSelected gives a callback when index changes we update it through controller
          onDestinationSelected: (index) => controller.selectedIndex.value = index,
          destinations: const [
            NavigationDestination(
              selectedIcon: Icon(Icons.home, color: AppColors.secondaryColor),
              icon: Icon(Icons.home_outlined, ),
              label: 'Home',
            ),
            NavigationDestination(
                selectedIcon: Icon(Icons.add_a_photo, color: AppColors.secondaryColor, ),
                icon: Icon(Icons.add_a_photo_outlined, ),
                label: ('Attendance'),
            ),
            NavigationDestination(
                selectedIcon: Icon(Icons.remove_red_eye_sharp, color: AppColors.secondaryColor ),
                icon: Icon(Icons.remove_red_eye_outlined, ),
                label: 'View'
            ),
            NavigationDestination(
                selectedIcon: Icon(Icons.account_circle_sharp, color: AppColors.secondaryColor),
                icon: Icon(Icons.account_circle_outlined),
                label: 'Profile'
            ),
          ],
        ),
      ),
      // displaying the screen[selectedIndex] wrapped with a observer from Get
      body: IndexedStack(
        children: [
          Obx( () => controller.screens[controller.selectedIndex.value]),
        ],
      ),
    );
  }
}

class NavigationController extends GetxController{
  // observing value of selectedIndex which is of the type Rx<int> which is by default a type we have to choose for Get
  final Rx<int> selectedIndex = 0.obs;
  final String uid;
  late final List<Widget> screens;

  //whenever initialized
  NavigationController({required this.uid}){
    //all the screens we will display
    screens = [
      Teacher(uid: uid),
      CaptureAttendance(teacherId: uid),
      const DateListScreen(RoleType: "View Attendance"),
      Container(color: Colors.blue)
    ];
  }
}
