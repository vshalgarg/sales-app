import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';

class CustomAppBar extends StatelessWidget implements PreferredSize {
  final String title;
  final TextStyle? textStyle;
  final Widget? leading;
  final List<Widget>? actions;


  const CustomAppBar({
    super.key,
    required this.title,
    this.textStyle,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      iconTheme: IconThemeData(color: Colors.white),
      backgroundColor: AppColors.bodyFillColor,
      title: Text(title, style: textStyle),
      leading: leading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget get child => throw UnimplementedError();
}
