import 'package:scan_io/constants.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class IconMenu extends StatelessWidget {
  final IconData icon;
  final String label;
  Function onPressed;
  int selectedIndex;
  int currIndex;
  IconMenu(
      {this.currIndex,
      this.icon,
      this.label,
      this.onPressed,
      this.selectedIndex});
  @override
  Widget build(BuildContext context) {
    bool selected = selectedIndex == currIndex;
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? secondary : textColor,
            ),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? secondary : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
