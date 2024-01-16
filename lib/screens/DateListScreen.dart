// @dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'AttendanceScreen.dart';
import 'package:intl/intl.dart';

import 'EditAttendance.dart';

class DateListScreen extends StatefulWidget {
  final String RoleType;
  const DateListScreen({Key key, @required this.RoleType}) : super(key: key);

  @override
  State<DateListScreen> createState() => _DateListScreenState();
}

class _DateListScreenState extends State<DateListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 
        Text(
          '${widget.RoleType}',
          style: GoogleFonts.ubuntu(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff508AA8),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white,)),
        shadowColor: Colors.blueGrey,
      ),
      body: FutureBuilder<List>(
        future: fetchDateListFromFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data.isEmpty) {
            return Center(child: Text('No dates found'));
          } else {
            List dateList = snapshot.data;
            return ListView.builder(
              itemCount: dateList.length,
              itemBuilder: (context, index) {
                String date = dateList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Card(
                    color: const Color(0xff508AA8),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ListTile(
                        title: Text(
                          "$date",
                          style: GoogleFonts.ubuntu(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          if(widget.RoleType=="Edit Attendance"){

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditAttendance(
                                courseCode: 'SE-312',
                                sessionDocumentId: 'session',
                                selectedDate: date,
                                RoleType: "Edit Attendance",
                              ),
                            ),
                          );
                          }
                          else{
                             Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditAttendance(
                                  courseCode: 'SE-312',
                                  sessionDocumentId: 'session',
                                  selectedDate: date,
                                  RoleType: "View Attendance",
                                ),
                              ),
                            );

                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List> fetchDateListFromFirebase() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('attendance') // Your main collection
              .doc('SE-312') // Replace with your actual course code
              .collection('session') // Collection containing session documents
              .get();

      List dateList = snapshot.docs
          .map((doc) => (doc['date'] ))
          .toList();

      // Remove duplicate dates if needed
      dateList = dateList.toSet().toList();

      // Sort the dates in descending order
      dateList.sort((a, b) => b.compareTo(a));

      return dateList;
    } catch (error) {
      print('Error fetching date list: $error');
      throw error;
    }
  }
}
