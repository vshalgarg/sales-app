import 'package:flutter/material.dart';

import '../constants/colors_used.dart';

class ScaffoldSnackBar {

  static void show(
      BuildContext context,
      String message, {
        Color backgroundColor = AppColors.containerFillColor,
      }) {

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(
        content: Text(message,style: TextStyle(color:Colors.black),),
        backgroundColor: backgroundColor,
        //behavior: SnackBarBehavior.floating,
      ),

    );
  }
}