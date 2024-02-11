//@dart=2.9
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DataStorage {
  static Future<Map<String, dynamic>> readDataFromFile() async {
    Directory savedFacesDir = await getApplicationDocumentsDirectory();
    String fullPathSavedFaces = savedFacesDir.path + '/savedFaces.json';
    File jsonFile = File(fullPathSavedFaces);

    if (jsonFile.existsSync()) {
      String fileContent = jsonFile.readAsStringSync();
      return json.decode(fileContent);
    } else {
      return {};
    }
  }

  static Future<void> writeDataToFile(Map<String, dynamic> data) async {
    Directory savedFacesDir = await getApplicationDocumentsDirectory();
    String fullPathSavedFaces = savedFacesDir.path + '/savedFaces.json';
    File jsonFile = File(fullPathSavedFaces);

    jsonFile.writeAsStringSync(json.encode(data));
  }

 
}
