import 'package:scan_io/constants.dart';
import 'package:scan_io/models/simpleFileModel.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ImageModel extends StatefulWidget {
  SimpleFileModel model;
  bool enabledBorder;
  int currIndex;
  int selectedIndex;
  int selectedFilter;
  Function changeSelectedIndex;
  Function removeSelectedIndex;
  ImageModel({
    this.model,
    this.enabledBorder,
    this.changeSelectedIndex,
    this.selectedIndex,
    this.currIndex,
    this.removeSelectedIndex,
    this.selectedFilter,
  });
  @override
  _ImageModelState createState() => _ImageModelState();
}

class _ImageModelState extends State<ImageModel> {
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height - 2 * kToolbarHeight;
    double w = MediaQuery.of(context).size.width;
    return Center(
      child: Container(
        height: h * 0.65,
        width: w * 0.75,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                PhysicalModel(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10.0),
                  elevation: 8.0,
                  child: Container(
                    height: h * 0.60,
                    width: w * 0.75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: tertiary,
                    ),
                    child: Center(
                      child: InkWell(
                        onTap: () {
                          fc.unfocus();
                          this
                              .widget
                              .changeSelectedIndex(this.widget.currIndex);
                        },
                        child: Container(
                          height: h * 0.55,
                          width: w * 0.7,
                          child: files[this.widget.currIndex].filterType == -1
                              ? Image.file(
                                  this.widget.model.file,
                                  fit: BoxFit.contain,
                                )
                              : ColorFiltered(
                                  colorFilter: ColorFilter.matrix(filtersList[
                                          files[this.widget.currIndex]
                                              .filterType]
                                      .value),
                                  child: Image.file(
                                    this.widget.model.file,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: InkWell(
                    onTap: () {
                      this.widget.removeSelectedIndex(this.widget.currIndex);
                    },
                    child: Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: secondary,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.clear,
                          size: 20,
                          color: white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              '(${this.widget.currIndex + 1})',
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
