//@dart = 2.9
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';

import 'DataStorage.dart';

class ViewLabel extends StatefulWidget {
  const ViewLabel({Key key}) : super(key: key);

  @override
  State<ViewLabel> createState() => _ViewLabelState();
}

class _ViewLabelState extends State<ViewLabel> {
  Future<Map<String, dynamic>> data;
  Future<Map<String, dynamic>> loadData() async {
    return DataStorage.readDataFromFile();
  }

  @override
  void initState() {
    super.initState();
    data = loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage User',
          style: GoogleFonts.ubuntu(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xff508AA8),
        centerTitle: true,
        shadowColor: Colors.blueGrey,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: true,
        actions: [
          PopupMenuButton(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
            ),
            onSelected: (String choice) {
              if (choice == 'reset') {
                deleteAllData();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'reset',
                  child: Text('Remove All Users'),
                ),
              ];
            },
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: loadData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show a loading indicator
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data.isEmpty) {
            return const Text('No data available');
          } else {
            Map<String, dynamic> data = snapshot.data;

            return ListView.builder(
              itemCount: data.keys.length,
              itemBuilder: (BuildContext context, int index) {
                String name = data.keys.elementAt(index);
                // String value = data[name].toString();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Card(
                    color: const Color(0xff508AA8),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: ListTile(
                          title: Text(
                            name,
                            style: GoogleFonts.ubuntu(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Text(
                              name[0],
                              style: GoogleFonts.ubuntu(
                                  color: const Color(0xff508AA8),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                          trailing: InkWell(
                              onTap: () {
                                deleteItem(name);
                              },
                              child: const Icon(
                                Icons.delete_rounded,
                                color: Colors.white,
                              ))),
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

  Future<void> deleteAllData() async {
    Map<String, dynamic> currentData = {};

    await DataStorage.writeDataToFile(currentData);

    setState(() {
      data = loadData();
    });
  }

  Future<void> deleteItem(String itemName) async {
    Map<String, dynamic> currentData = await data;
    currentData.remove(itemName);

    await DataStorage.writeDataToFile(currentData);

    setState(() {
      data = loadData();
    });
  }
}
