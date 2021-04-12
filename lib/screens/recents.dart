import 'dart:async';
import 'dart:io';
import 'package:scan_io/constants.dart';
import 'package:scan_io/screens/createFiles.dart';
import 'package:scan_io/models/fileModel.dart';
import 'package:scan_io/widgets/search.dart';
import 'package:scan_io/models/simpleFileModel.dart';
import 'package:scan_io/widgets/bottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'dart:math' as math;

class RecentScreen extends StatefulWidget {
  @override
  _RecentScreenState createState() => _RecentScreenState();
}

class _RecentScreenState extends State<RecentScreen> {
  List<FileModel> recentFiles = [];
  List<DropdownMenuItem> dropdownItems;
  String selectedMode = "By Time (Newest First)";
  String path;
  double _width = 0.0;
  @override
  void initState() {
    dropdownItems = [];
    dropdownItems.add(DropdownMenuItem(
      child: Text(
        "By Time (Newest First)",
      ),
      value: "By Time (Newest First)",
    ));
    dropdownItems.add(DropdownMenuItem(
      child: Text(
        "By Time (Oldest First)",
      ),
      value: "By Time (Oldest First)",
    ));
    dropdownItems.add(DropdownMenuItem(
      child: Text(
        "By Size (High-To-Low)",
      ),
      value: "By Size (High-To-Low)",
    ));
    dropdownItems.add(DropdownMenuItem(
      child: Text(
        "By Size (Low-To-High)",
      ),
      value: "By Size (Low-To-High)",
    ));
    dropdownItems.add(DropdownMenuItem(
      child: Text(
        "By Name (A-To-Z)",
      ),
      value: "By Name (A-To-Z)",
    ));
    dropdownItems.add(DropdownMenuItem(
      child: Text(
        "By Name (Z-To-A)",
      ),
      value: "By Name (Z-To-A)",
    ));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  StreamController getRecentList() {
    StreamController streamController = StreamController();
    Directory directory = Directory(directoryPath);
    print('---------------> $directoryPath');
    recentFiles.clear();
    directory.listSync().forEach((element) {
      path = element.path;
      print(element.path);
      String fileName = path.substring(path.lastIndexOf('/') + 1);
      File file = new File(path);
      int bytes = file.lengthSync();
      String size = bytesToSize(bytes, 2);
      DateTime time = file.lastModifiedSync();
      String dateTime = DateFormat('yyyy/MM/dd, HH:mm').format(time);
      FileModel fileModel = FileModel(
        fileName: fileName,
        fileSize: bytes,
        filePath: path,
        filesSizeString: size,
        creationDate: dateTime,
        lastModified: time,
      );
      recentFiles.add(fileModel);
      if (selectedMode == "By Time (Newest First)") {
        recentFiles.sort((a, b) => b.lastModified.millisecondsSinceEpoch
            .compareTo(a.lastModified.millisecondsSinceEpoch));
      } else if (selectedMode == "By Time (Oldest First)") {
        recentFiles.sort((a, b) => a.lastModified.millisecondsSinceEpoch
            .compareTo(b.lastModified.millisecondsSinceEpoch));
      } else if (selectedMode == "By Size (High-To-Low)") {
        recentFiles.sort((a, b) => b.fileSize.compareTo(a.fileSize));
      } else if (selectedMode == "By Size (Low-To-High)") {
        recentFiles.sort((a, b) => a.fileSize.compareTo(b.fileSize));
      } else if (selectedMode == "By Name (A-To-Z)") {
        recentFiles.sort((a, b) {
          String aa = a.fileName.substring(a.fileName.lastIndexOf("/") + 1);
          String bb = b.fileName.substring(b.fileName.lastIndexOf("/") + 1);
          return aa.compareTo(bb);
        });
        recentFiles.forEach((e) => print('---> ${e.fileName}'));
      } else {
        recentFiles.sort((a, b) {
          String aa = a.fileName.substring(a.fileName.lastIndexOf("/") + 1);
          String bb = b.fileName.substring(b.fileName.lastIndexOf("/") + 1);
          return bb.compareTo(aa);
        });
        recentFiles.forEach((e) => print('---> ${e.fileName}'));
      }
    });
    print('=====================');
    recentFiles.forEach((element) {
      print(element.fileName);
    });
    print('=====================');
    streamController.add(recentFiles);
    return streamController;
  }

  bytesToSize(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (math.log(bytes) / math.log(1024)).floor();
    return ((bytes / math.pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  showSheet(BuildContext context, int i) async {
    String file = await showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        builder: (context) {
          return MyBottomSheet(
            fileModel: recentFiles[i],
            i: i,
            search: false,
          );
        });
    if (file != null) {
      recentFiles[i].filePath = file;
      String fileName = path.substring(path.lastIndexOf('/') + 1);
      recentFiles[i].fileName = fileName;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width * 0.3;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 8.0,
          backgroundColor: primary,
          title: Text(
            "Scan.io",
            style: TextStyle(
                color: tertiary,
                fontWeight: FontWeight.normal,
                letterSpacing: 1.2),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search_rounded),
              onPressed: () async {
                List<FileModel> temp = [];
                temp.addAll(recentFiles);
                temp = await showSearch(
                  context: context,
                  delegate: SearchFile(
                    recentModels: temp,
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: tertiary,
        body: StreamBuilder(
            stream: getRecentList().stream,
            builder: (context, snapshot) {
              return Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: tertiary,
                    child: recentFiles.isNotEmpty
                        ? Scrollbar(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: recentFiles.length + 1,
                              padding: EdgeInsets.symmetric(horizontal: 5.0),
                              itemBuilder: (context, index) {
                                if (index == 0) return sortWidget();
                                int i = index - 1;
                                return ListTile(
                                  onTap: () async {
                                    await OpenFile.open(
                                        recentFiles[i].filePath);
                                  },
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.more_vert_rounded,
                                    ),
                                    onPressed: () {
                                      showSheet(context, i);
                                    },
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: secondary,
                                    child: Text(
                                      recentFiles[i].fileName[0].toUpperCase(),
                                      style: TextStyle(
                                        color: white,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    recentFiles[i].fileName,
                                    style: TextStyle(
                                      color: textColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    recentFiles[i].creationDate,
                                    style: TextStyle(color: textColor),
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.hourglass_empty_rounded,
                                  size: 50,
                                  color: secondary,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "No Files Found!!",
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    letterSpacing: 1.2,
                                    color: secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        width: _width,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          color: secondary,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () async {
                                SimpleFileModel model =
                                    await fetchCameraImage(context);
                                if (model != null) {
                                  files.add(model);
                                }
                                setState(() {});
                                if (files.isNotEmpty) {
                                  String fileName = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateScreen(
                                          modify: false, fileName: null),
                                    ),
                                  );
                                  files.clear();
                                  pickedFile = null;
                                  if (fileName != null) {
                                    String filePath =
                                        directoryPath + '/$fileName.pdf';
                                    await OpenFile.open('$filePath');
                                    setState(() {});
                                  }
                                }
                              },
                              child: Icon(
                                Icons.camera_alt,
                                color: white,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              child: VerticalDivider(
                                thickness: 1.0,
                                color: white,
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                List<SimpleFileModel> list =
                                    await fetchImages(context);
                                files.addAll(list);
                                setState(() {});
                                if (files.isNotEmpty) {
                                  String fileName = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateScreen(
                                          modify: false, fileName: null),
                                    ),
                                  );
                                  files.clear();
                                  pickedFile = null;
                                  if (fileName != null) {
                                    String filePath =
                                        directoryPath + '/$fileName.pdf';
                                    await OpenFile.open('$filePath');
                                    setState(() {});
                                  }
                                }
                              },
                              child: Icon(
                                Icons.photo_library_sharp,
                                color: white,
                              ),
                            ),
                          ],
                        ),
                      ))
                ],
              );
            }),
      ),
    );
  }

  sortWidget() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      margin: EdgeInsets.symmetric(horizontal: 20.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: DropdownButton(
          isExpanded: true,
          icon: Icon(Icons.sort_rounded),
          iconSize: 30.0,
          items: dropdownItems,
          iconEnabledColor: textColor,
          selectedItemBuilder: (context) {
            return List.generate(dropdownItems.length, (index) {
              return Container(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    dropdownItems[index].value,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: textColor,
                      letterSpacing: 1.2,
                      fontFamily: "Segoe",
                    ),
                  ),
                ),
              );
            });
          },
          style: TextStyle(
            color: black,
            letterSpacing: 1.2,
            fontFamily: "Segoe",
          ),
          value: selectedMode,
          onChanged: (val) {
            selectedMode = val;
            setState(() {});
          },
        ),
      ),
    );
  }
}
