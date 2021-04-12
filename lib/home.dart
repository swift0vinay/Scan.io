import 'dart:io';
import 'package:scan_io/constants.dart';
import 'package:scan_io/screens/recents.dart';
import 'package:scan_io/models/pdfModel.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  bool loading = false;
  bool access = false;
  @override
  void initState() {
    super.initState();
    access = false;
    check();
  }

  check() async {
    setState(() {
      loading = true;
    });
    Directory directory = await getExternalStorageDirectory();
    String path =
        directory.path.substring(1, directory.path.lastIndexOf("0/") + 1);
    bool iHave = await Permission.storage.isGranted;
    Directory newDirectory = Directory("$path/scanned_docs");
    if (iHave) {
      directoryPath = newDirectory.path;
      setState(() {
        access = true;
      });
    } else {
      PermissionStatus status =
          await Permission.storage.request().catchError((e) {});
      if (status.isGranted) {
        newDirectory =
            await newDirectory.create().catchError((e) {}).then((value) {
          return value;
        });
        directoryPath = newDirectory.path;
        setState(() {
          access = true;
        });
      }
    }
    if (access) {
      Directory directory = await getApplicationDocumentsDirectory();
      Hive.init(directory.path);
      scanIoBox = await Hive.openBox(boxName);
      if (scanIoBox.isNotEmpty) getFileFromBox();
    }

    setState(() {
      loading = false;
    });
  }

  getFileFromBox() {
    pdfModels.clear();
    for (int i = 0; i < scanIoBox.length; i++) {
      Map<String, dynamic> map = Map.from(scanIoBox.getAt(i));
      PdfModel model = PdfModel().fromMap(map);
      pdfModels.add(model);
    }
    print('=============================');
    print(pdfModels);
    print('=============================');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: access ? primary : tertiary,
      appBar: access
          ? null
          : AppBar(
              elevation: 8.0,
              backgroundColor: primary,
              title: Text(
                "Scan.io",
                style: TextStyle(
                    color: tertiary,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 1.2),
              ),
            ),
      body: loading
          ? Container(
              color: tertiary,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(white),
                ),
              ),
            )
          : decideWidget(),
    );
  }

  decideWidget() {
    return access
        ? RecentScreen()
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Permission Denied!!",
                  style: TextStyle(
                    fontSize: 18.0,
                    color: textColor,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: secondary,
                  ),
                  onPressed: () {
                    check();
                  },
                  child: Text("Tap To Give Access"),
                ),
              ],
            ),
          );
  }
}
