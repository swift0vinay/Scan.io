import 'package:scan_io/constants.dart';
import 'package:scan_io/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Segoe",
        accentColor: primary,
        primaryColor: primary,
      ),
      title: 'Scan.io',
      debugShowCheckedModeBanner: false,
      home: MyHome(),
    );
  }
}
/*
Scan Docs
Set correct Aspect Ratio 
Share Files
Ad free Maybe
Responsive
*/
