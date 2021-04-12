import 'dart:io';
import 'dart:typed_data';
import 'package:scan_io/models/filterMode.dart';
import 'package:scan_io/models/pdfModel.dart';
import 'package:scan_io/models/simpleFileModel.dart';
import 'package:scan_io/widgets/filters.dart';
import 'package:scan_io/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

Box scanIoBox;

String directoryPath;
String boxName = 'scan_io';
String primaryHex = "#009688";
String secondaryHex = primaryHex;
Color primary = Colors.teal;
Color secondary = primary;
Color tertiary = Color(0xffF9F5F4);
Color textColor = Colors.black;
Color black = Colors.black;
Color black26 = Colors.black26;
Color black54 = Colors.black54;
Color black87 = Colors.black87;
Color white = Colors.white;

List<PdfModel> pdfModels = [];
List<SimpleFileModel> files = [];
PickedFile pickedFile;
bool fileAdded = false;
FocusNode fc;
final String methodChannel = "SCAN_IO";
List<FilterMode> filtersList = [
  new FilterMode(filterName: "No Filter", value: NONE),
  new FilterMode(filterName: "B & W", value: BlackAndWhite),
  new FilterMode(filterName: "Lighten", value: Lighten),
  new FilterMode(filterName: "Darken", value: Darken),
  new FilterMode(filterName: "GrayScale", value: GrayScale),
  new FilterMode(filterName: "Invert", value: Invert),
  new FilterMode(filterName: "Sepia", value: Sepia),
];
Future<SimpleFileModel> fetchCameraImage(BuildContext context) async {
  showDialog(
      context: context,
      builder: (context) {
        return Loader();
      });
  PickedFile file = await ImagePicker()
      .getImage(source: ImageSource.camera, imageQuality: 20);
  if (file == null) {
    Navigator.pop(context);
    return null;
  }
  SimpleFileModel simpleFileModel = new SimpleFileModel();
  simpleFileModel.filePath = file.path;
  simpleFileModel.file = new File(file.path);
  simpleFileModel.filterType = -1;
  Navigator.pop(context);
  return simpleFileModel;
}

Future<List<SimpleFileModel>> fetchImages(BuildContext context) async {
  List<Asset> imageList = [];
  List<SimpleFileModel> list = [];

  imageList = await MultiImagePicker.pickImages(
    maxImages: 100,
    enableCamera: true,
    materialOptions: MaterialOptions(
      actionBarColor: primaryHex,
      statusBarColor: primaryHex,
      actionBarTitle: "Select Images",
      allViewTitle: "All Photos",
      useDetailsView: false,
      autoCloseOnSelectionLimit: true,
      selectCircleStrokeColor: secondaryHex,
    ),
  ).catchError((e) {
    print(e.toString());
  });

  Directory directory = Directory.systemTemp;
  print(directory.path);
  String filePaths = '${directory.path}/';
  print(imageList);
  showDialog(
      context: context,
      builder: (context) {
        return Loader();
      });
  if (imageList == null || imageList.isEmpty) {
    Navigator.pop(context);
    return [];
  }
  for (int i = 0; i < imageList.length; i++) {
    Asset element = imageList[i];
    ByteData byteData = await element.getByteData(quality: 20);
    String fileName = element.name;
    var buffer = byteData.buffer;
    String filePath = '$filePaths$fileName';
    File file = File(filePath);
    file = await file.writeAsBytes(
        buffer.asInt8List(byteData.offsetInBytes, byteData.lengthInBytes));
    SimpleFileModel simpleFileModel = SimpleFileModel();
    simpleFileModel.file = file;
    simpleFileModel.filePath = filePath;
    simpleFileModel.filterType = -1;
    list.add(simpleFileModel);
  }
  Navigator.pop(context);
  return list;
}
