// @dart=2.9
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import '../global/styles.dart';
import '../utils/PermissionHelper.dart';
import 'LoginPage.dart';
import 'package:flutter_editable_table/constants.dart';
import 'package:flutter_editable_table/flutter_editable_table.dart';
import 'package:intl/intl.dart';


class EditAttendance extends StatefulWidget {
  final String courseCode;
  final String sessionDocumentId;
  final String selectedDate;
  final String RoleType;

  const EditAttendance(
      {Key key,
      @required this.courseCode,
      @required this.sessionDocumentId,
      @required this.selectedDate,
      @required this.RoleType});

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
            "${widget.RoleType}",
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
          actions: widget.RoleType == 'Edit Attendance'
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
                          ?.currentData.isFilled}');
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
          ]
              : []),
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
            Uint8List pdfBytes = await buildPdf(snapshot, courseCode);
            await savePdf(pdfBytes);
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

                      /*
                    // Get the previous rows
                    List<Object> currentRows = currentData.rows ?? [];
                    print('currentRows: $currentRows');

                    var addedRows = currentRows[0];
                    print(addedRows);

                    List<Map<String, dynamic>> tableRows = mapFirebaseDataToTableRows(attendanceData);
                    print('previousRows: $tableRows');
                    // Find the added row by comparing the previous and current rows
                    List<Map<String, dynamic>> addedRows = currentRows
                        .where((currentRow) => !previousRows.contains(currentRow))
                        .toList();
                    // Check if there is at least one added row*/
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

/*
// Function to update Firebase data with the new row
  Future<void> updateFirebaseData(String studentName) async {
    try {
      // Get the current attendance data from Firebase
      DocumentSnapshot<Map<String, dynamic>> snapshot = await getAttendanceData();
      Map<String, dynamic> attendanceData = snapshot.data() ?? {};

      // Update the relevant fields in attendanceData
      attendanceData['presentStudents'] = [
        ...List<String>.from(attendanceData['presentStudents'] ?? []),
        studentName,
      ];

      // Update the document in Firebase
      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(widget.courseCode)
          .collection('session')
          .doc(widget.sessionDocumentId)
          .update(attendanceData);

    } catch (error) {
      print('Error updating Firebase data: $error');
    }
  }
*/

  // Function to update Firebase data with the new status for a student
  Future<void> updateStudentStatus(String studentName, String status) async {
    try {
      // Get the current attendance data from Firebase
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await getAttendanceData();
      Map<String, dynamic> attendanceData = snapshot.data() ?? {};

      // Update the relevant fields in attendanceData
      Map<String, dynamic> attendanceList =
      Map<String, dynamic>.from(attendanceData['attendanceList'] ?? {});

      // Update the status for the specific student
      attendanceList[studentName] = status;

      // Update the attendanceData with the modified attendanceList
      attendanceData['attendanceList'] = attendanceList;

      // Update the document in Firebase
      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(widget.courseCode)
          .collection('session')
          .doc(widget.sessionDocumentId)
          .update(attendanceData);
    } catch (error) {
      print('Error updating Firebase data: $error');
    }
  }

  // generate the pdf
  Future<Uint8List> buildPdf(
      DocumentSnapshot<Map<String, dynamic>> attendanceData,
      String courseCode) async {
    // Create the Pdf document
    final pw.Document doc = pw.Document();

    // Load the image from assets
    final Uint8List imageList = (await rootBundle.load('assets/ned_logo.png'))
        .buffer.asUint8List();

    // Add one page with centered text "Hello World"
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
                  pw.Text('Attendance Report', style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 20),

              // Attendance Information
              pw.Text('Course: $courseCode',
                  style: const pw.TextStyle(fontSize: 16)),
              pw.Text('Section: ${attendanceData['section']}',
                  style: const pw.TextStyle(fontSize: 16)),
              pw.Text('Session Date: ${attendanceData['date']}',
                  style: const pw.TextStyle(fontSize: 16)),

              pw.SizedBox(height: 20),

              // Table with Absent and Present Students
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.IntrinsicColumnWidth(),
                  1: const pw.IntrinsicColumnWidth(),
                },
                children: [
                  pw.TableRow(children: [
                    pw.Text('Absent Students', style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Present Students', style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  ]),
                  pw.TableRow(children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: (attendanceData['attendanceList'] as Map<
                          dynamic,
                          dynamic>)
                          .entries
                          .where((entry) => entry.value == 'Absent')
                          .map((entry) {
                        return pw.Text(entry.key.toString());
                      }).toList(),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: (attendanceData['attendanceList'] as Map<
                          dynamic,
                          dynamic>)
                          .entries
                          .where((entry) => entry.value == 'Present')
                          .map((entry) {
                        return pw.Text(entry.key.toString());
                      }).toList(),
                    ),
                  ]),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Build and return the final Pdf file data
    return await doc.save();
  }

  // save the pdf using provider in system path
  Future<void> savePdf(Uint8List pdfBytes) async {
    final granted = await PermissionHelper.requestStoragePermissions();
    if (!granted) {
      // Get the list of external storage directories
      Directory directories = await getExternalStorageDirectory();
      Directory generalDownloadDir = Directory(
          '/storage/emulated/0/Download'); // THIS WORKS for android only !!!!!!

      print('director: $directories');
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Writing Permission Denied, Allow from Settings'),
          duration: Duration(seconds: 5),
        ));
      }
    }
  }


// Future<void> showNotification(String pdfPath) async {
//   await AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: 0,
//       channelKey: 'basic_channel',
//       title: 'PDF Generated',
//       body: 'Tap to Open!',
//       actionType: ActionType.Default,
//       notificationLayout: NotificationLayout.BigText,
//       payload: {'pdfPath': pdfPath},
//     ),
//     actionButtons: [
//       NotificationActionButton(
//         key: 'openPdfAction',
//         label: 'Open PDF',
//       ),
//     ],
//   );
// }
