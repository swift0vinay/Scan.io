import 'dart:io';
import 'dart:math';
import 'package:scan_io/constants.dart';
import 'package:scan_io/screens/reoder.dart';
import 'package:scan_io/models/pdfModel.dart';
import 'package:scan_io/models/simpleFileModel.dart';
import 'package:scan_io/widgets/confirmDialog.dart';
import 'package:scan_io/widgets/createFilter.dart';
import 'package:scan_io/widgets/iconMenu.dart';
import 'package:scan_io/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:scan_io/widgets/imageModel.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class CreateScreen extends StatefulWidget {
  bool modify;
  String fileName;
  CreateScreen({@required this.modify, @required this.fileName});
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  int selectedImageIndex = 0;
  int currIconIndex = 0;
  int selectedFilter = 0;
  bool change = false;
  bool showLoading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _textEditingController;
  PageController _pageController;
  DateTime dateTime;
  @override
  void initState() {
    super.initState();
    fc = FocusNode();
    dateTime = DateTime.now();
    Random random = new Random();
    String zs = "";
    selectedImageIndex = 0;
    change = false;
    int counter = 4;
    while (counter > 0) {
      int x = random.nextInt(10);
      zs += '$x';
      --counter;
    }
    String time = DateFormat('yyyy-MMM-dd').format(dateTime) + '-$zs';
    _textEditingController = TextEditingController(
        text: this.widget.fileName == null ? time : this.widget.fileName);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _pageController = PageController(viewportFraction: 0.85);
    print(files);
    return WillPopScope(
      onWillPop: () async {
        bool rs = await showDialog(
            context: context,
            builder: (context) {
              return ConfirmDialog(
                  text: "Any Progress will be lost!!",
                  yes: "Leave",
                  no: "Cancel");
            });
        if (rs) {
          Navigator.pop(context, null);
          return Future.value(true);
        } else {
          return Future.value(false);
        }
      },
      child: Scaffold(
        backgroundColor: tertiary,
        key: _scaffoldKey,
        appBar: AppBar(
          elevation: 8.0,
          iconTheme: IconThemeData(color: tertiary),
          title: Text(
            "Create",
            style: TextStyle(
              color: tertiary,
              fontWeight: FontWeight.normal,
              letterSpacing: 1.2,
            ),
          ),
          backgroundColor: primary,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 5.0),
              child: AnimatedCrossFade(
                duration: Duration(milliseconds: 500),
                crossFadeState: showLoading
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                secondChild: Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          tertiary,
                        ),
                      ),
                    ),
                  ),
                ),
                firstChild: InkWell(
                  onTap: () {
                    createPdf();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    child: Center(
                      child: Center(
                        child: Icon(
                          Icons.check,
                          color: tertiary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        resizeToAvoidBottomInset: false,
        body: listallFile(),
      ),
    );
  }

  void changeSelectedIndex(int currIndex) {
    setState(() {
      selectedImageIndex = currIndex;
    });
    print(selectedImageIndex);
  }

  void removeSelectedIndex(int currIndex) {
    files.removeAt(currIndex);
    setState(() {});
    if (files.isEmpty) {
      Navigator.pop(context, null);
    }
  }

  void changeSelectedFilter(int index) {
    selectedFilter = index;
    setState(() {});
  }

  Widget listallFile() {
    double h = MediaQuery.of(context).size.height -
        AppBar().preferredSize.height -
        MediaQuery.of(context).padding.top;
    double w = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        children: [
          container1(h, w),
          container2(h),
          tempContainer(h),
          container3(h),
        ],
      ),
    );
  }

  Container container1(double h, double w) {
    return Container(
      height: h * 0.08,
      width: w * 0.9,
      alignment: Alignment.topCenter,
      child: TextFormField(
        focusNode: fc,
        enabled: !this.widget.modify,
        cursorRadius: Radius.zero,
        controller: _textEditingController,
        cursorColor: secondary,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
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
    );
  }

  AnimatedContainer container2(double h) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      alignment: Alignment.topCenter,
      height: change ? h * 0.66 : h * 0.84,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        itemCount: files.length,
        onPageChanged: (index) {
          setState(() {
            selectedImageIndex = index;
          });
        },
        controller: _pageController,
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, i) {
          return ImageModel(
            model: files[i],
            changeSelectedIndex: changeSelectedIndex,
            currIndex: i,
            selectedIndex: selectedImageIndex,
            removeSelectedIndex: removeSelectedIndex,
            selectedFilter: selectedFilter,
          );
        },
      ),
    );
  }

  AnimatedContainer tempContainer(double h) {
    return AnimatedContainer(
      color: Colors.grey.withOpacity(0.5),
      height: change ? h * 0.18 : 0,
      duration: Duration(milliseconds: 200),
      alignment: Alignment.bottomCenter,
      child: change ? addPhotos() : SizedBox.shrink(),
    );
  }

  Container container3(double h) {
    return Container(
      height: h * 0.08,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconMenu(
              icon: Icons.add_circle_outline_outlined,
              label: "Add",
              onPressed: () async {
                fc.unfocus();
                setState(() {
                  currIconIndex = 0;
                  change = !change;
                });
              },
              selectedIndex: currIconIndex,
              currIndex: 0),
          IconMenu(
            icon: Icons.crop,
            label: "Crop",
            onPressed: () {
              fc.unfocus();
              setState(() {
                currIconIndex = 1;
                change = false;
              });
              _cropImage(selectedImageIndex);
            },
            selectedIndex: currIconIndex,
            currIndex: 1,
          ),
          IconMenu(
            icon: Icons.filter,
            label: "Filter",
            onPressed: () async {
              fc.unfocus();
              currIconIndex = 2;
              change = false;
              int op = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return CreateFilter(
                  selectedImageIndex: selectedImageIndex,
                );
              }));
              if (op != null) {
                files[selectedImageIndex].filterType = op;
              }
              setState(() {});
            },
            selectedIndex: currIconIndex,
            currIndex: 2,
          ),
          IconMenu(
            icon: Icons.swap_horiz_rounded,
            label: "Reorder",
            onPressed: () async {
              fc.unfocus();
              currIconIndex = 3;
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Reorder(),
                ),
              );
              setState(() {});
            },
            selectedIndex: currIconIndex,
            currIndex: 3,
          ),
          IconMenu(
            icon: Icons.check_circle_outline_outlined,
            label: "Done",
            onPressed: () {
              fc.unfocus();
              setState(() {
                currIconIndex = 4;
                change = false;
              });
              createPdf();
            },
            selectedIndex: currIconIndex,
            currIndex: 4,
          ),
        ],
      ),
    );
  }

  Future<void> _cropImage(int index) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: files[index].filePath,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: primary,
            toolbarWidgetColor: tertiary,
            backgroundColor: tertiary,
            statusBarColor: primary,
            activeControlsWidgetColor: primary,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      showDialog(
          context: context,
          builder: (context) {
            return Loader();
          });
      // File newFile = File(files[index].filePath);
      // Uint8List list = await croppedFile.readAsBytes().catchError((e) {
      //   print("CANT CATCH $e");
      // });
      // File againNewFile = new File(files[index].filePath);
      // againNewFile = await newFile.writeAsBytes(list).catchError((e) {
      //   print(e.toString());
      // });
      // await newFile.delete().catchError((e) {
      //   print("CANT DELETE");
      // }).then((val) {
      //   print("DELETED");
      // });
      // print(againNewFile.path);
      SimpleFileModel newModel = new SimpleFileModel();
      newModel.filePath = croppedFile.path;
      newModel.file = croppedFile;
      newModel.filterType = files[selectedImageIndex].filterType;
      files[index] = newModel;
      setState(() {});
      Navigator.pop(context);
    }
  }

  Widget addPhotos() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ListTile(
            onTap: () async {
              SimpleFileModel model = await fetchCameraImage(context);
              if (model != null) {
                files.add(model);
                await _pageController.animateToPage(files.length - 1,
                    duration: Duration(milliseconds: 500), curve: Curves.ease);
              }
              setState(() {});
            },
            leading: Icon(
              Icons.camera,
              color: tertiary,
            ),
            title: Text(
              "Capture from Camera",
              style: TextStyle(
                fontSize: 15.0,
                letterSpacing: 1.2,
                color: tertiary,
              ),
            ),
          ),
          ListTile(
            onTap: () async {
              List<SimpleFileModel> list = await fetchImages(context);
              int prev = files.length;
              files.addAll(list);
              if (list.isNotEmpty) {
                change = false;
              }
              int next = files.length;
              if (next != prev) {
                await _pageController.animateToPage(prev,
                    duration: Duration(milliseconds: 500), curve: Curves.ease);
              }
              setState(() {});
            },
            leading: Icon(
              Icons.photo_library_sharp,
              color: tertiary,
            ),
            title: Text(
              "Select from Photos",
              style: TextStyle(
                fontSize: 15.0,
                letterSpacing: 1.2,
                color: tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> createPdf() async {
    fc.unfocus();
    bool rr = _textEditingController.text.contains(".pdf");
    String fileName;
    if (rr) {
      int index = _textEditingController.text.lastIndexOf(".pdf");
      fileName = _textEditingController.text.substring(0, index);
    } else {
      fileName = _textEditingController.text;
    }
    int alreadyPresent =
        pdfModels.indexWhere((element) => element.fileName == fileName);
    if (alreadyPresent != -1) {
      bool ss = await showDialog(
        context: context,
        builder: (context) => ConfirmDialog(
          text: "File with this name already exists!",
          okCancel: "Ok",
        ),
      );
    } else {
      print('1111111111111111111111111111111');
      print(scanIoBox.values);
      print(pdfModels);
      print('1111111111111111111111111111111');
      PdfModel pdfModel = PdfModel();
      pdfModel.fileName = fileName;
      pdfModel.modelList = [];
      pdfModel.modelList.addAll(files);
      List<Map<String, dynamic>> listOfFiles = [];
      files.forEach((element) {
        listOfFiles.add(element.toMap());
      });
      bool rs = await showDialog(
          context: context,
          builder: (context) {
            return ConfirmDialog(
              text: "Are you sure?",
            );
          });
      if (rs) {
        setState(() {
          showLoading = true;
        });
        Future.delayed(Duration(seconds: 2)).then((value) async {
          var channel = new MethodChannel(methodChannel);
          await channel.invokeMethod(
            'create',
            <String, dynamic>{
              'height': 1300,
              'width': 900,
              'files': listOfFiles,
              'directoryPath': directoryPath,
              'fileName': fileName,
            },
          ).then((value) async {
            for (int i = 0; i < scanIoBox.length; i++) {
              Map<String, dynamic> map = Map.from(scanIoBox.getAt(i));
              if (map['fileName'] == fileName) {
                await scanIoBox.deleteAt(i);
                break;
              }
            }
            scanIoBox.add(pdfModel.toMap());
            if (this.widget.modify) {
              pdfModels.removeWhere((element) => element.fileName == fileName);
            }
            pdfModels.add(pdfModel);
            print('2222222222222222222222');
            print(scanIoBox.values);
            print(pdfModels);
            print('2222222222222222222222');
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("File Saved Successfully!",
                  style: TextStyle(
                    color: white,
                    fontSize: 15.0,
                  )),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ));
            print(pdfModels.length);
            Future.delayed(Duration(seconds: 2)).then((value) {
              Navigator.pop(context, fileName);
            });
          }).catchError((e) {
            print(e.toString());
          });
          setState(() {
            showLoading = false;
          });
        });
      }
    }
  }
}
