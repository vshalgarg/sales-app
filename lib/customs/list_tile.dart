import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Color? textColor;
  final double? textSize;
  final Color? tileColor;
  final Color? selectedTileColor;
  final TextStyle? textStyle;

  const CustomListTile({
    super.key,
    required this.title,
    this.onTap,
    this.textColor,
    this.textSize,
    this.tileColor,
    this.selectedTileColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: textStyle,
      ),
      onTap: onTap,
      tileColor: tileColor,
      selectedTileColor: selectedTileColor,
    );
  }
}
