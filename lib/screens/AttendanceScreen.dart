// @dart=2.9
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../global/styles.dart';
import '../utils/PDFHelper.dart';
import 'package:flutter_editable_table/constants.dart';
import 'package:flutter_editable_table/flutter_editable_table.dart';

import 'Teacher/teacher_nav_bar.dart';


class EditAttendance extends StatefulWidget {
  final String courseCode;
  final String sessionDocumentId;
  final String selectedDate;
  final String roleType;

  const EditAttendance(
      {Key key,
      @required this.courseCode,
      @required this.sessionDocumentId,
      @required this.selectedDate,
      @required this.roleType}) : super(key: key);

  @override
  EditAttendanceState createState() => EditAttendanceState();
}

class EditAttendanceState extends State<EditAttendance> {
  Future<DocumentSnapshot<Map<String, dynamic>>> attendanceData;

  final _editableTableKey = GlobalKey<EditableTableState>();

  bool editing = false;

  @override
  void initState() {
    attendanceData = getAttendanceData();
    super.initState();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getAttendanceData() async {
    // Convert the selectedDate to a string or a format compatible with your data
    // String selectedDateString =
    //     DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    return FirebaseFirestore.instance
        .collection('attendance')
        .doc(widget.courseCode)
        .collection('session')
        .where('date', isEqualTo: widget.selectedDate)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first;
      } else {
        // Handle the case where no data is found for the selected date
        throw Exception("No data found for the selected date");
      }
    });
  }

  // Function to map Firebase data to table rows
  List<Map<String, dynamic>> mapFirebaseDataToTableRows(
      Map<String, dynamic> attendanceData) {
    List<Map<String, dynamic>> rows = [];

    // Extract the required fields from the attendanceData
    List<String> presentStudents =
    List<String>.from(attendanceData['presentStudents'] ?? []);

    // Map present Students data to table rows
    for (String student in presentStudents) {
      rows.add({
        "name": student, // Assuming "name" is the key in your table data
        // Add other relevant fields here
      });
    }

    return rows;
  }

  // Function to map Firebase data to table rows for attendanceList
  List<Map<String, dynamic>> mapAttendanceListToTableRows(
      Map<String, dynamic> attendanceData) {
    List<Map<String, dynamic>> rows = [];

    // Extract the attendanceList from the attendanceData
    Map<String, dynamic> attendanceList =
    Map<String, dynamic>.from(attendanceData['attendanceList'] ?? {});

    // Map attendanceList data to table rows
    attendanceList.forEach((String student, dynamic attendanceStatus) {
      rows.add({
        "name": student,
        "status":
        attendanceStatus,
        // Assuming "status" is the key in your table data for attendance status
        // Add other relevant fields here
      });
    });
    return rows;
  }

  Map<String, Object> constructTableData(List<Map<String, dynamic>> rows,
      String section, String date, String courseCode) {
    return {
      "column_count": null,
      "row_count": null,
      "addable": true,
      "removable": true,
      "caption": {
        "layout_direction": "row",
        "main_caption": {
          "title": " $courseCode Attendance",
          "display": true,
          "editable": false,
          "style": {
            "font_weight": "bold",
            "font_size": 20.0,
            "font_color": "#333333",
            "background_color": null,
            "horizontal_alignment": "center",
            "vertical_alignment": "center",
            "text_align": "center"
          }
        },
      },
      "columns": [
        /*    {
        "primary_key": true,
        "title":"Roll Number",
        "name": "id",
        "type": "int",
        "format": null,
        "description": null,
        "display": false,
        "editable": false,
        "style": {
          "font_weight": "bold",
          "font_size": 14.0,
          "font_color": "#333333",
          "background_color": "#b5cfd2",
          "horizontal_alignment": "center",
          "vertical_alignment": "center",
          "text_align": "center"
        }
      },
      {
        "auto_increase": true,
        "type": "int",
        "format": "Step __VALUE__",
        "description": null,
        "display": true,
        "editable": false,
        "width_factor": 0.2,
        "style": {
          "font_weight": "bold",
          "font_size": 14.0,
          "font_color": "#333333",
          "background_color": "#b5cfd2",
          "horizontal_alignment": "center",
          "vertical_alignment": "center",
          "text_align": "center"
        }
      },*/

        {
          "name": "name",
          "title": "Name",
          "type": "string",
          "format": null,
          "description": "Name",
          "display": true,
          "editable": true,
          "width_factor": 0.6,
          "input_decoration": {
            "min_lines": 1,
            "max_lines": 1,
            "max_length": 20,
            "hint_text": "Please input FirstName - rollNum"
          },
          "constraints": {"required": true, "minimum": 1, "maximum": 120},
          "style": {
            "font_weight": "bold",
            "font_size": 14.0,
            "font_color": "#333333",
            "background_color": "#508aa8",
            "horizontal_alignment": "center",
            "vertical_alignment": "center",
            "text_align": "center"
          }
        },
        {
          "name": "status",
          "title": "Status",
          "type": "string",
          "format": null,
          "description": "Present - or - Absent?",
          "display": true,
          "editable": true,
          "width_factor": 0.3,
          "input_decoration": {
            "min_lines": 1,
            "max_lines": 1,
            "max_length": 8,
            "hint_text": "Type Present or Absent"
          },
          "constrains": {"required": true, "minimum": -100, "maximum": 10000},
          "style": {
            "font_weight": "bold",
            "font_size": 14.0,
            "font_color": "#333333",
            "background_color": "#508aa8",
            "horizontal_alignment": "center",
            "vertical_alignment": "center",
            "text_align": "center"
          }
        },
      ],
      "rows": rows,
      "footer": {
        "layout_direction": "row",
        "content": [
          {
            "title": "Section: $section",
            "display": true,
            "editable": false,
            "style": {
              "font_weight": "bold",
              "font_size": 14.0,
              "font_color": "#333333",
              "background_color": null,
              "horizontal_alignment": "center",
              "vertical_alignment": "center",
              "text_align": "center"
            }
          },
          {
            "title": "Date: $date",
            "display": true,
            "editable": false,
            "style": {
              "font_weight": "bold",
              "font_size": 12.0,
              "font_color": "#333333",
              "background_color": null,
              "horizontal_alignment": "center",
              "vertical_alignment": "center",
              "text_align": "center"
            }
          },
        ]
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "${widget.roleType}",
            style: GoogleFonts.ubuntu(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.secondaryColor,
          centerTitle: true,
          shadowColor: Colors.blueGrey,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded, color: Colors.white,)),
          actions: widget.roleType == 'Edit Attendance'
              ? [
            const SizedBox(width: 8.0),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                WidgetsBinding.instance.focusManager.primaryFocus
                    ?.unfocus();
                _editableTableKey.currentState?.readOnly = editing;
                setState(() {
                  editing = !editing;
                });
                if (!editing) {
                  print(
                      'table filling status: ${_editableTableKey.currentState
                          ?.currentData?.isFilled}');
                  final currentData =
                      _editableTableKey.currentState?.currentData;
                  // Check if currentData is not null
                  if (currentData != null) {
                    // Get the previous rows
                    List<Object> currentRows = currentData.rows ?? [];
                    print('currentRows: $currentRows');

                    DocumentSnapshot<Map<String, dynamic>> snapshot =
                    await attendanceData;
                    var firebaseDocument = snapshot.data();

                    List<Map<String, dynamic>> previousRows =
                    mapFirebaseDataToTableRows(firebaseDocument);
                    print('previousRows: $previousRows');

                    int currentLength = currentRows.length;
                    int previousLength = previousRows.length;
                    int diff = currentLength - previousLength;

                    print(currentRows[currentLength + diff].toString());

                    // Print the runtime type of each item in currentRows
                    currentRows.forEach((item) {
                      print('Item type: ${item.runtimeType}');
                      String stringItem = item.toString();
                      var s = stringItem;
                      print(s);
                      var x = json.decode(stringItem);
                      print(x);
                    });
                  } else {
                    print('No current data found');
                  }
                }
              },
              child: Icon(
                !editing ? Icons.edit : Icons.check,
                color: Colors.white,
              ),
            ),
          ] : []),
      bottomNavigationBar: const TeacherNavMenu(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondaryColor,
        tooltip: 'Print Document',
        onPressed: () async {
          // Wait for the attendanceData Future to complete
          DocumentSnapshot<Map<String, dynamic>> snapshot =
          await attendanceData;
          print(snapshot);
          print('attendance: $attendanceData.size');
          final courseCode = widget.courseCode;
          // Check if the snapshot contains data
          if (snapshot.exists) {
            PDFHelper pdfHelper = PDFHelper(); // Create an instance of PDFHelper
            Uint8List pdfBytes = await pdfHelper.buildGeneralPdf(snapshot, courseCode);
            await pdfHelper.savePdf(pdfBytes, widget.selectedDate, context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('No data found'),
              duration: Duration(seconds: 5),
            ));
          }
        },
        child: const Icon(Icons.print, color: Colors.white),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: attendanceData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                CircularProgressIndicator()); // Loading indicator while data is being fetched
          }
          if (!snapshot.hasData || !snapshot.data.exists) {
            return const Text(
                'No data found'); // Handle the case where the document doesn't exist
          }

          final attendanceDataMap = snapshot.data.data();
          print('attendanceData: $attendanceDataMap');

          // Extract the required fields from the attendanceData
          /* List<String> absentStudents = List<String>.from(attendanceDataMap['absentStudents'] ?? []);
        List<String> presentStudents = List<String>.from(attendanceDataMap['presentStudents'] ?? []);
        print(absentStudents);*/

          // Assuming attendanceList is a Map<String, dynamic> in attendanceData
          Map<String, dynamic> attendanceList = Map<String, dynamic>.from(
              attendanceDataMap['attendanceList'] ?? {});

          // Now you can iterate over the map entries
          attendanceList.forEach((key, value) {
            // key is the student name, and value is the attendance status
            print('$key: $value');
          });

          // If you specifically want a list of student names, you can get the keys

          print('attendanceList: $attendanceList');

          // Map Firebase data to table rows
          List<Map<String, dynamic>> tableRows =
          mapAttendanceListToTableRows(attendanceDataMap);
          print('tableRows: $tableRows');
          /*var lmao = tableRows[0];
        print(lmao);*/

          // Rows formatted to pass to EditableTable()
          final rows = tableRows;
          String section = attendanceDataMap['section'] ?? '';
          String date = attendanceDataMap['date'];
          // String formattedDate =
          //     DateFormat('dd-MMMM-yyyy HH:mm:ss');
          final courseCode = widget.courseCode;
          //print(formattedDate);

          final data = constructTableData(rows, section, date, courseCode);
          return SingleChildScrollView(
            padding: EdgeInsets.all(12.0),
            child: Center(
              child: EditableTable(
                  captionTextStyle: const TextStyle(color: Colors.black),
                  key: _editableTableKey,
                  data: data,
                  readOnly: true,
                  tablePadding: EdgeInsets.all(8.0),
                  captionBorder: const Border(
                    top: BorderSide(color: Color(0xFF999999)),
                    left: BorderSide(color: Color(0xFF999999)),
                    right: BorderSide(color: Color(0xFF999999)),
                  ),
                  headerBorder: Border.all(color: Color(0xFF999999)),
                  rowBorder: Border.all(color: Color(0xFF999999)),
                  footerBorder: Border.all(color: Color(0xFF999999)),
                  removeRowIcon: const Icon(
                    Icons.remove_circle_outline,
                    size: 24.0,
                    color: AppColors.accentColor,
                  ),
                  addRowIcon: const Icon(
                    Icons.add_circle_outline,
                    size: 24.0,
                    color: Colors.white,
                  ),
                  addRowIconContainerBackgroundColor: AppColors.secondaryColor,
                  formFieldAutoValidateMode: AutovalidateMode.always,
                  onRowRemoved: (row) {
                    print('row removed: ${row.toString()}');
                  },
                  onRowAdded: () async {},
                  onFilling: (FillingArea area, dynamic value) {
                    print(
                        'filling: ${area.toString()}, value: ${value
                            .toString()}');
                  },
                  onSubmitted: (FillingArea area, dynamic value) async {
                    print('lmao');
                    // Get the current data from the EditableTable
                    print('FilingArea: $area , value: ${value.toString()}');
                    String status = value.toString();
                    final currentData =
                        _editableTableKey.currentState?.currentData;

                    // Assuming "name" is the key for the student's name in your table data
                    String columnName = "name";
                    String studentName = area.name.toString();
                    print(studentName);

                    // Check if currentData is not null
                    if (currentData != null) {
                      // Update the Firebase data with the new row
                      await updateStudentStatus("FAIQ - 95", status);

                      // Print information for debugging
                      print('Row added: $status');
                      print(
                          'Updated Firebase data: ${await getAttendanceData()}');
                    } else {
                      print('No added row found');
                    }
                  }),
            ),
          );
        },
      ),
    );
  }


  // Function to update Firebase data with the new status for a student
  Future<void> updateStudentStatus(String studentName, String status) async {
    try {
      // Get the current attendance data from Firebase
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(widget.courseCode)
          .collection('session')
          .where('date', isEqualTo: widget.selectedDate)
          .get();

      // Check if any documents match the query
      if (snapshot.docs.isNotEmpty) {
        // Get the document reference of the first (and presumably only) document
        DocumentReference attendanceDocRef = snapshot.docs.first.reference;

        // Get the existing data
        Map<String, dynamic> attendanceData = snapshot.docs.first.data();

        // Update the relevant fields in attendanceData
        Map<String, dynamic> attendanceList =
        Map<String, dynamic>.from(attendanceData['attendanceList'] ?? {});

        // Update the status for the specific student
        attendanceList[studentName] = status;

        // Update the attendanceData with the modified attendanceList
        attendanceData['attendanceList'] = attendanceList;
        print('session: ${widget.selectedDate}');

        // Update the document in Firebase
        await attendanceDocRef.update(attendanceData);
      } else {
        print('No document found for the selected date');
      }
    } catch (error) {
      print('Error updating Firebase data: $error');
    }
  }
}

