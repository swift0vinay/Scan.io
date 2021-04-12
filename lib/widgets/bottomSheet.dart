import 'dart:io';
import 'package:scan_io/constants.dart';
import 'package:scan_io/screens/createFiles.dart';
import 'package:scan_io/widgets/confirmDialog.dart';
import 'package:scan_io/models/fileModel.dart';
import 'package:scan_io/models/pdfModel.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:share/share.dart';

// ignore: must_be_immutable
class MyBottomSheet extends StatefulWidget {
  FileModel fileModel;
  int i;
  bool search;
  MyBottomSheet({
    @required this.fileModel,
    @required this.i,
    @required this.search,
  });
  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  TextEditingController textEditingController;
  TextEditingController textEditingController2;
  TextEditingController textEditingController3;

  bool enabled = false;
  String newName;
  @override
  void initState() {
    super.initState();
    textEditingController =
        TextEditingController(text: this.widget.fileModel.fileName);
    textEditingController2 =
        TextEditingController(text: this.widget.fileModel.creationDate);
    textEditingController3 =
        TextEditingController(text: this.widget.fileModel.filesSizeString);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    textEditingController2.dispose();
    textEditingController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: TextField(
              controller: textEditingController,
              enabled: enabled,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
              ),
              cursorColor: secondary,
              decoration: InputDecoration(
                suffixIcon: enabled
                    ? InkWell(
                        child: Icon(
                          Icons.check,
                          color: secondary,
                        ),
                        onTap: () async {
                          bool rs = await showDialog(
                              context: context,
                              builder: (context) {
                                return ConfirmDialog(
                                  text: "Apply Changes ? ",
                                );
                              });
                          if (rs) {
                            File file = File(this.widget.fileModel.filePath);
                            String temp =
                                this.widget.fileModel.filePath.substring(
                                      0,
                                      this
                                              .widget
                                              .fileModel
                                              .filePath
                                              .lastIndexOf('/') +
                                          1,
                                    );
                            int indexx = this
                                .widget
                                .fileModel
                                .fileName
                                .lastIndexOf(".pdf");
                            String prevName = this
                                .widget
                                .fileModel
                                .fileName
                                .substring(0, indexx);
                            bool rs =
                                textEditingController.text.endsWith(".pdf");
                            String fileName;
                            if (rs) {
                              int index = textEditingController.text
                                  .lastIndexOf(".pdf");
                              fileName = textEditingController.text
                                  .substring(0, index);
                              temp += textEditingController.text;
                            } else {
                              fileName = textEditingController.text;
                              temp += textEditingController.text + ".pdf";
                            }
                            print('333333333333333333333333');
                            print(scanIoBox.values);
                            print(pdfModels);

                            print('333333333333333333333333');
                            file = await file.rename(temp);
                            int i = pdfModels.indexWhere(
                                (element) => element.fileName == prevName);
                            PdfModel pdfModel = pdfModels[i];
                            for (int i = 0; i < scanIoBox.length; i++) {
                              Map<String, dynamic> map =
                                  Map.from(scanIoBox.getAt(i));
                              if (map['fileName'] == prevName) {
                                await scanIoBox.deleteAt(i);
                                break;
                              }
                            }
                            pdfModel.fileName = fileName;
                            scanIoBox.add(pdfModel.toMap());
                            pdfModels[i] = pdfModel;
                            print('4444444444444444444444444');
                            print(scanIoBox.values);
                            print(pdfModels);

                            print('4444444444444444444444444');

                            Navigator.pop(context, temp);
                          }
                        },
                      )
                    : null,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: secondary,
                  ),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: secondary,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: secondary,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Last Modified :",
                  style: TextStyle(fontSize: 15.0),
                ),
                Text(
                  textEditingController2.text,
                  style: TextStyle(fontSize: 15.0),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Size :",
                  style: TextStyle(fontSize: 15.0),
                ),
                Text(
                  textEditingController3.text,
                  style: TextStyle(fontSize: 15.0),
                ),
              ],
            ),
          ),
          ListTile(
            onTap: () async {
              await OpenFile.open(this.widget.fileModel.filePath);
            },
            leading: Icon(Icons.folder_open_rounded),
            title: Text("Open"),
          ),
          ListTile(
            onTap: () async {
              await Share.shareFiles([this.widget.fileModel.filePath]);
              Navigator.pop(context);
            },
            title: Text("Share"),
            leading: Icon(
              Icons.share,
            ),
          ),
          this.widget.search
              ? SizedBox.shrink()
              : ListTile(
                  onTap: () {
                    setState(() {
                      enabled = true;
                    });
                    print(enabled);
                  },
                  title: Text("Rename"),
                  leading: Icon(
                    Icons.edit,
                  ),
                ),
          this.widget.search
              ? SizedBox.shrink()
              : ListTile(
                  onTap: () async {
                    String fileName = textEditingController.text.substring(
                        0, textEditingController.text.lastIndexOf('.pdf'));
                    int index = pdfModels
                        .indexWhere((element) => element.fileName == fileName);
                    files.addAll(pdfModels[index].modelList);
                    setState(() {});
                    if (files.isNotEmpty) {
                      String fn = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CreateScreen(modify: true, fileName: fileName),
                        ),
                      );
                      files.clear();
                      pickedFile = null;
                      if (fn != null) {
                        String filePath = directoryPath + '/$fn.pdf';
                        await OpenFile.open('$filePath');
                        setState(() {});
                        Navigator.pop(context, null);
                      }
                    }
                  },
                  title: Text("Modify Scan"),
                  leading: Icon(Icons.file_copy),
                ),
          this.widget.search
              ? SizedBox.shrink()
              : ListTile(
                  onTap: () async {
                    bool rs = await showDialog(
                        context: context,
                        builder: (context) {
                          return ConfirmDialog(
                            text: "Are you sure?",
                          );
                        });
                    if (rs) {
                      File file = new File(this.widget.fileModel.filePath);
                      int index =
                          textEditingController.text.lastIndexOf(".pdf");
                      String fileName =
                          textEditingController.text.substring(0, index);
                      pdfModels.removeWhere(
                          (element) => element.fileName == fileName);
                      for (int i = 0; i < scanIoBox.length; i++) {
                        Map<String, dynamic> map = Map.from(scanIoBox.getAt(i));
                        if (map['fileName'] == fileName) {
                          await scanIoBox.deleteAt(i);
                          break;
                        }
                      }
                      file.delete();
                      setState(() {});
                      Navigator.pop(context);
                    }
                  },
                  title: Text("Delete"),
                  leading: Icon(
                    Icons.delete,
                  ),
                ),
        ],
      ),
    );
  }
}
