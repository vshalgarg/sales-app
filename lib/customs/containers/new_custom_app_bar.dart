import 'package:flutter/material.dart';

import '../../constants/colors_used.dart';

class NewCustomAppBar extends StatelessWidget implements  PreferredSizeWidget {
  const NewCustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);


  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(7.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.primaryPurple,
          ),
          child: Center(
            child: Text(
              "h",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,fontSize: 18),
            ),
          ),
        ),
      ),
      title: Text(
        "hissabio",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryPurple,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(7.0),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryPurpleLight,
            child: Text(
              "A",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryPurple,
              ),
            ),
          ),
        ),

      ],
    );
  }


}
