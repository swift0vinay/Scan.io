import 'package:scan_io/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// ignore: must_be_immutable
class CreateFilter extends StatefulWidget {
  int selectedImageIndex;
  CreateFilter({
    @required this.selectedImageIndex,
  });
  @override
  _CreateFilterState createState() => _CreateFilterState();
}

class _CreateFilterState extends State<CreateFilter> {
  double h;
  int selectedImageIndex;
  int selectedFilter = 0;
  @override
  void initState() {
    super.initState();
    selectedFilter = 0;
    selectedImageIndex = this.widget.selectedImageIndex;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height -
        kToolbarHeight -
        MediaQuery.of(context).padding.top;

    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, null);
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: tertiary,
        appBar: AppBar(
          elevation: 8.0,
          iconTheme: IconThemeData(color: tertiary),
          backgroundColor: primary,
          title: Text(
            "Apply Filter",
            style: TextStyle(
              color: tertiary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.check,
                  color: tertiary,
                ),
                onPressed: () {
                  Navigator.pop(context, selectedFilter);
                })
          ],
        ),
        body: Column(
          children: [
            Container(
              height: h * 0.80,
              width: MediaQuery.of(context).size.width,
              color: tertiary,
              padding: EdgeInsets.all(20.0),
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix(
                  filtersList[selectedFilter].value,
                ),
                child: Image.file(
                  files[this.widget.selectedImageIndex].file,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              height: h * 0.20,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: black26,
                    width: 1.5,
                  ),
                ),
              ),
              child: Scrollbar(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                  // shrinkWrap: true,
                  itemCount: filtersList.length,
                  separatorBuilder: (context, i) {
                    return Container(
                      width: 20,
                      child: VerticalDivider(
                        color: black54,
                        width: 1.5,
                      ),
                    );
                  },
                  itemBuilder: (context, i) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedFilter = i;
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: h * 0.13,
                            width: width * 0.3,
                            decoration: BoxDecoration(
                              border: selectedFilter == i
                                  ? Border.all(color: secondary, width: 2.0)
                                  : null,
                            ),
                            child: ColorFiltered(
                              colorFilter:
                                  ColorFilter.matrix(filtersList[i].value),
                              child: Image.file(
                                files[selectedImageIndex].file,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            filtersList[i].filterName,
                            style: TextStyle(
                              color: textColor,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
