import 'package:scan_io/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChooseOption extends StatefulWidget {
  @override
  _ChooseOptionState createState() => _ChooseOptionState();
}

class _ChooseOptionState extends State<ChooseOption>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 200));
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0, end: 1).animate(animationController),
      child: Center(
        child: Material(
          borderRadius: BorderRadius.circular(20.0),
          elevation: 10.0,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () async {
                    pickedFile = await ImagePicker()
                        .getImage(
                      source: ImageSource.camera,
                      imageQuality: 40,
                    )
                        .catchError((e) {
                      print(e.toString());
                    });
                    if (pickedFile == null) {
                      Navigator.pop(context, "");
                    } else {
                      Navigator.pop(context, pickedFile.path);
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera,
                        color: white,
                        size: 40,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Camera",
                        style: TextStyle(
                          fontSize: 18.0,
                          letterSpacing: 1.2,
                          color: secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () async {
                    pickedFile = await ImagePicker()
                        .getImage(
                      source: ImageSource.gallery,
                      imageQuality: 40,
                    )
                        .catchError((e) {
                      print(e.toString());
                    });
                    if (pickedFile == null) {
                      Navigator.pop(context, "");
                    } else {
                      Navigator.pop(context, pickedFile.path);
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library_rounded,
                        color: white,
                        size: 40,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Gallery",
                        style: TextStyle(
                          fontSize: 18.0,
                          letterSpacing: 1.2,
                          color: secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
