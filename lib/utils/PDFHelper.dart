import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'PermissionHelper.dart';
import 'package:pdf/widgets.dart' as pw;


//provides savePdf and buildPdf methods.
class PDFHelper {
  // generate the pdf
  Future<Uint8List> buildGeneralPdf(DocumentSnapshot<Map<String, dynamic>> attendanceData, String courseCode) async {
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

  Future<void> savePdf(Uint8List pdfBytes, String uniqueName,
      BuildContext context) async {
    final granted = await PermissionHelper.requestStoragePermissions();
    String fileName = formatFileName(uniqueName);

    try {
      if (Platform.isAndroid) {
        if (granted) {
          // Get the list of external storage directories
          Directory generalDownloadDir = Directory(
              '/storage/emulated/0/Download'); // THIS WORKS for android only !!!!!!


          final String path = '${generalDownloadDir.path}/$fileName';
          print('path: $path');

          // Save the Pdf file
          final File file = File(path);
          await file.writeAsBytes(pdfBytes);

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
      } else {
        // IOS
        if (granted) {
          // Get the application documents directory path for iOS (may need later functionality to
          // be added to save directly in files)
          final directories = await getApplicationDocumentsDirectory();
          final path = '${directories.path}/$fileName';

          // Save the Pdf file
          final File file = File(path);
          await file.writeAsBytes(pdfBytes);

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
    } catch (e) {
      throw Exception(e);
    }
  }

  //for student, it will be studentName to save a file uniquely, while for admin and teacher,
  // it will be selected date of a session

  String formatFileName(String uniqueName) {
    //perform string manipulation to generate a valid filename
    uniqueName = uniqueName.replaceAll(' ', '-');
    uniqueName = uniqueName.replaceAll(':', '-');
    String fileName = '$uniqueName-attendanceReport.pdf';
    return fileName;
  }

  Future<Uint8List> buildStudentPdf(List<Map<String, dynamic>> overallAttendanceList, String studentName) async {
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
                  pw.Text('Attendance Report: $studentName', style: pw.TextStyle(
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
                  ['Course Code', 'Total Classes', 'Present Count', 'Absent Count', 'Attendance Percentage'],
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

}

