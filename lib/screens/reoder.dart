import 'package:scan_io/constants.dart';
import 'package:scan_io/models/simpleFileModel.dart';
import 'package:drag_and_drop_gridview/devdrag.dart';
import 'package:flutter/material.dart';

class Reorder extends StatefulWidget {
  @override
  _ReorderState createState() => _ReorderState();
}

class _ReorderState extends State<Reorder> {
  double w;
  @override
  Widget build(BuildContext context) {
    w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        elevation: 8.0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: tertiary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: primary,
        title: Text(
          "Reorder",
          style: TextStyle(
            color: tertiary,
            letterSpacing: 1.2,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      backgroundColor: tertiary,
      body: DragAndDropGridView(
          onReorder: (int oldIndex, int newIndex) {
            SimpleFileModel simpleFileModel = files[oldIndex];
            files[oldIndex] = files[newIndex];
            files[newIndex] = simpleFileModel;
            setState(() {});
          },
          onWillAccept: (int oldIndex, int newIndex) {
            return true;
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: w * 0.025,
            mainAxisSpacing: w * 0.025,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.025,
            vertical: w * 0.025,
          ),
          itemCount: files.length,
          itemBuilder: (context, i) {
            return Stack(
              children: [
                Container(
                  height: w * 0.3,
                  width: w * 0.3,
                  decoration: BoxDecoration(
                    color: tertiary,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: secondary, width: 1.5),
                  ),
                  child: Image.file(files[i].file, fit: BoxFit.contain),
                ),
                Positioned(
                  left: 5,
                  top: 5,
                  child: CircleAvatar(
                    backgroundColor: primary,
                    radius: 8,
                    child: Center(
                      child: Text(
                        "${i + 1}",
                        style: TextStyle(
                          color: white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
