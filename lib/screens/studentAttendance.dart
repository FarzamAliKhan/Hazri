// @dart=2.9
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../global/styles.dart';
import '../utils/PermissionHelper.dart';
import 'LoginPage.dart';
import 'package:flutter_editable_table/constants.dart';
import 'package:flutter_editable_table/flutter_editable_table.dart';
import 'package:intl/intl.dart';


class StudentAttendance extends StatefulWidget {
  final String studentName; // Add a parameter for the student ID
  final String roleType; // Add a parameter for the student ID

  const StudentAttendance({Key key, @required this.studentName, this.roleType});

  @override
  StudentAttendanceState createState() => StudentAttendanceState();
}

class StudentAttendanceState extends State<StudentAttendance> {
  Future<List<Map<String, dynamic>>> attendanceData;

  final _editableTableKey = GlobalKey<EditableTableState>();

  bool editing = false;

  @override
  void initState() {
    attendanceData = getOverallAttendanceData(widget.studentName);
    super.initState();
  }

Future<List<Map<String, dynamic>>> getOverallAttendanceData(String studentName) async {
  // Fetch all documents from the attendance collection
  QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('attendance').get();

  // Process each course document to calculate attendance metrics
  List<Map<String, dynamic>> overallAttendanceList = [];

  // Iterate over each course document
  for (QueryDocumentSnapshot<Map<String, dynamic>> document in querySnapshot.docs) {
    // Get the course data
    Map<String, dynamic> courseData = document.data();

    print('courseData: $courseData');

    String courseName = courseData['name'];

    // Initialize counts for each course
    int totalSessions = 0;
    int presentCount = 0;
    int absentCount = 0;
    double attendancePercentage = 0.0;

    // Get the 'session' subcollection reference
    CollectionReference<Map<String, dynamic>> sessionCollection =
        document.reference.collection('session');

    // Query the 'session' subcollection
    QuerySnapshot<Map<String, dynamic>> sessionSnapshot = await sessionCollection.get();

    // Iterate over each session in the course
    for (QueryDocumentSnapshot<Map<String, dynamic>> sessionDocument in sessionSnapshot.docs) {
      Map<String, dynamic> sessionData = sessionDocument.data();
      print('session: $sessionData');

      // Increment the totalSessions count
      totalSessions++;

      // Get the attendanceList for the session
      Map<String, dynamic> attendanceList = sessionData['attendanceList'];

      print('attendanceList: $attendanceList');

      // Find the attendance status for the specified student
      String studentAttendanceStatus = attendanceList.entries
          .firstWhere(
            (entry) {
              // Split the entry key by hyphen
              List<String> parts = entry.key.split(' - ');

              // Check if the lowercase name part matches the provided studentName
              return parts[0].toLowerCase() == studentName.toLowerCase();
            },
            orElse: () => null,
          )
          ?.value;

      // If the student is found in the attendance list for a session
      if (studentAttendanceStatus != null) {
        if (studentAttendanceStatus == 'Present') {
          presentCount++;
        } else if (studentAttendanceStatus == 'Absent') {
          absentCount++;
        }
      }
    }

        if (totalSessions != null && presentCount != null && totalSessions > 0) {
      attendancePercentage = (presentCount / totalSessions) * 100.0;
      print(totalSessions);
      print(presentCount);
      print(attendancePercentage);
    } else {
          const Text('No Present Classes Found for You');
        }

        print('hi');

    // Add course data to the overallAttendanceList
    overallAttendanceList.add({
      'courseCode': courseName,
      'totalSessions': totalSessions,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'attendancePercentage': attendancePercentage,
    });
  }
  print(overallAttendanceList);

  return overallAttendanceList;

}

  Map<String, Object> constructTableData(List<Map<String, dynamic>> overallAttendanceList) {
    return {
      "column_count": null,
      "row_count": null,
      "addable": true,
      "removable": true,
      "caption": {
        "layout_direction": "row",
        "main_caption": {
          "title": "  Attendance",
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
          "name": "courseCode",
          "title": "Course",
          "type": "string",
          "format": null,
          "description": "Name",
          "display": true,
          "editable": true,
          "width_factor": 0.2,
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
          "name": "totalSessions",
          "title": "Total Classes",
          "type": "int",
          "format": null,
          "description": "Present - or - Absent?",
          "display": true,
          "editable": true,
          "width_factor": 0.2,
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
        {
          "name": "presentCount",
          "title": "Present Classes",
          "type": "int",
          "format": null,
          "description": "Present - or - Absent?",
          "display": true,
          "editable": true,
          "width_factor": 0.2,
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
        {
          "name": "absentCount",
          "title": "Absent Classes",
          "type": "int",
          "format": null,
          "description": "Present - or - Absent?",
          "display": true,
          "editable": true,
          "width_factor": 0.2,
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
        {
          "name": "attendancePercentage",
          "title": "Total Attendance",
          "type": "int",
          "format": null,
          "description": "Present - or - Absent?",
          "display": true,
          "editable": true,
          "width_factor": 0.2,
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
      "rows": overallAttendanceList,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            widget.studentName,
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
          actions: widget.studentName == 'Edit Attendance'
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
                }
              },
              child: Icon(
                !editing ? Icons.edit : Icons.check,
                color: Colors.white,
              ),
            ),
          ]
              : []),
      floatingActionButton: widget.roleType == "Report Generate"
        ? FloatingActionButton(
        backgroundColor: AppColors.secondaryColor,
        tooltip: 'Print Document',
        onPressed: () async {
          // Wait for the attendanceData Future to complete
          List<Map<String, dynamic>> snapshot =
              await attendanceData;
          print('attendance: $snapshot');
          // Check if the snapshot contains data
          if (snapshot.isNotEmpty) {
            Uint8List pdfBytes = await buildStudentPdf(snapshot);
            await savePdf(pdfBytes);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('No data found'),
              duration: Duration(seconds: 5),
            ));
          }
        },
        child: const Icon(Icons.print, color: Colors.white),
      )
    : null,
      body: FutureBuilder<List<Map<String, dynamic>>>(
  future: attendanceData,
  builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data.isEmpty) {
          return const Text('No data found');
        }

        final List<Map<String, dynamic>> attendanceDataList = snapshot.data;

        print('attendanceDataList: $attendanceDataList');

        // Map Firebase data to table rows
        List<Map<String, dynamic>> tableRows = [];
        attendanceDataList.forEach((attendanceDataMap) {
          // Assuming attendanceList is a Map<String, dynamic> in attendanceData
          Map<String, dynamic> attendanceList =
          Map<String, dynamic>.from(attendanceDataMap['attendanceList'] ?? {});

          print("attendanceDataMap $attendanceDataMap");

          // Add course data to the tableRows
          tableRows.add({
            'courseCode': attendanceDataMap['courseCode'],
            'totalSessions': attendanceDataMap['totalSessions'],
            'presentCount': attendanceDataMap['presentCount'],
            'absentCount': attendanceDataMap['absentCount'],
            'attendancePercentage': attendanceDataMap['attendancePercentage'],
          });
        });

        // Rows formatted to pass to EditableTable()
        final rows = tableRows;
        print('tablerows: $tableRows');

        // Data formatted to pass to EditableTable()
        final data = constructTableData(rows);
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

                  }),
            ),
          );
        },
      ),
    );
  }
Future<Uint8List> buildStudentPdf(List<Map<String, dynamic>> overallAttendanceList) async {
  // Create the Pdf document
  final pw.Document doc = pw.Document();

  // Load the image from assets
  final Uint8List imageList = (await rootBundle.load('assets/ned_logo.png'))
      .buffer.asUint8List();

  // Add a page for each course in the overallAttendanceList
  for (Map<String, dynamic> courseData in overallAttendanceList) {
    // Add a new page
    doc.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Section with Logo and Title
              pw.Row(
                children: [
                  pw.Image(pw.MemoryImage(imageList), width: 100, height: 100),
                  pw.SizedBox(width: 20),
                  pw.Text('Attendance Report: ${widget.studentName}', style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 20),

              // Course Information Table
              pw.Table.fromTextArray(
                context: context,
                border: null,
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: const pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(2)),
                  color: PdfColors.grey300,
                ),
                headerHeight: 25,
                cellHeight: 25,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerLeft,
                  4: pw.Alignment.centerLeft,
                },
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
                data: [
                  ['Course Code', 'Total Sessions', 'Present Count', 'Absent Count', 'Attendance Percentage'],
                  [courseData['courseCode'], courseData['totalSessions'].toString(), courseData['presentCount'].toString(), courseData['absentCount'].toString(), courseData['attendancePercentage'].toString()],
                ],
              ),

              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  // Build and return the final Pdf file data
  return await doc.save();
}

  // save the pdf using provider in system path
  Future<void> savePdf(Uint8List pdfBytes) async {
    final granted = await PermissionHelper.requestStoragePermissions();
      // Get the list of external storage directories
      Directory directories = await getExternalStorageDirectory();
      Directory generalDownloadDir = Directory(
          '/storage/emulated/0/Download'); // THIS WORKS for android only !!!!!!

      print('directory: $directories');
      // Check if there's a valid directory in the list
      //if (directories != null && directories.isNotEmpty) {
        // Use the first directory in the list
        //final Directory directory = directories[0];
        final String path = '${generalDownloadDir.path}/attendance_report.pdf';

        // Save the Pdf file
        final File file = File(path);
        await file.writeAsBytes(pdfBytes);
        print('path: $path');

        // Show a notification
        // showNotification(path);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('PDF saved at: $path'),
          duration: Duration(seconds: 5),
        ));

      }
    }

