import 'package:flutter/material.dart';

Widget customIcon({
  required IconData icon,
  required Color iconColor,
  required Color bgColor,
}) {
  return Padding(
    padding: const EdgeInsets.all(2.0),
    child: Center(
      child: Icon(
        icon,
        color: iconColor,
        size: 22,
      ),
    ),
  );
}