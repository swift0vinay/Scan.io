import 'package:scan_io/constants.dart';
import 'package:flutter/material.dart';

class ConfirmDialog extends StatefulWidget {
  final String text;
  final String yes;
  final String no;
  final String okCancel;
  ConfirmDialog({
    this.text,
    this.yes,
    this.no,
    this.okCancel,
  });
  @override
  _ConfirmDialogState createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
    );
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
      scale: Tween<double>(begin: 0, end: 1.0).animate(animationController),
      child: Center(
        child: Material(
          elevation: 0.0,
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.9,
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: tertiary,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  this.widget.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor, fontSize: 18.0),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: this.widget.okCancel == null
                      ? [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: secondary,
                            ),
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: Text(
                              this.widget.yes == null ? "Yes" : this.widget.yes,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: secondary,
                            ),
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: Text(
                              this.widget.no == null ? "No" : this.widget.no,
                            ),
                          )
                        ]
                      : [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: secondary,
                            ),
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: Text(
                              "OK",
                            ),
                          )
                        ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
