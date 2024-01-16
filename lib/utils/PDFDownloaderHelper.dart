import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PDFDownloaderHelper {
  static Future<void> savePDF(Uint8List pdfBytes ,String fileName) async {
    try {
      if (Platform.isAndroid) {
        // Check if the platform is Android
        final directory = Directory("/storage/emulated/0/Download");

        if (!directory.existsSync()) {
          // Create the directory if it doesn't exist
          await directory.create();
        }
        final path = '${directory.path}/$fileName';
        final File file = File(path);
        await file.writeAsBytes(pdfBytes);
        // showNotification(path);
        print('PDF saved at: $path');

      } else {
        // IOS
        final directories = await getApplicationDocumentsDirectory();
        // Get the application documents directory path
        final path = '${directories.path}/$fileName';

        //final Directory directory = directories[0];
       // final String path = '${directories.path}/attendance_report.pdf';

        // Save the Pdf file
        final File file = File(path);
        await file.writeAsBytes(pdfBytes);

        // Show a notification
        // showNotification(path);

        print('PDF saved at: $path');

        final res = await Share.shareXFiles([XFile(path, bytes: pdfBytes)]);
        // showNotification(path);
        print('PDF saved at: $path');

      }
    } catch (e) {
      throw Exception(e);
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