import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';

class CustomAppBar extends StatelessWidget implements PreferredSize {
  final String title;
  final TextStyle? textStyle;

  const CustomAppBar({super.key, required this.title, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: const BorderRadius.vertical(
      bottom: Radius.circular(40),
    ),
      child: AppBar(
        iconTheme: IconThemeData(color:Colors.white),
       // centerTitle: true,
        backgroundColor: AppColors.primaryPurple,
        title: Text(title, style: textStyle),
        actions: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Icon(Icons.settings,size:30),
          )],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget get child => throw UnimplementedError();
}
