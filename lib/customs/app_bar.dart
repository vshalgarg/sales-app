import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';

class CustomAppBar extends StatelessWidget implements PreferredSize {
  final String title;
  final TextStyle? textStyle;
  const CustomAppBar({super.key, required this.title, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        iconTheme: IconThemeData(color:Colors.white),
       // centerTitle: true,
        backgroundColor: AppColors.bodyFillColor,
        title: Text(title, style: textStyle),


    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget get child => throw UnimplementedError();
}
