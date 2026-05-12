import 'package:flutter/material.dart';

Widget customIcon({
  required IconData icon,
  required Color iconColor,
  required Color bgColor,
}) {
  return Container(
   // height: 40,
    //width: 40,
    decoration: BoxDecoration(
      color: bgColor,
      shape: BoxShape.circle,
    ),
    child: Padding(
      padding: const EdgeInsets.all(4.0),
      child: Center(
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
    ),
  );
}