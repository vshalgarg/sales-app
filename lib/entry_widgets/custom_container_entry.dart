import 'package:flutter/material.dart';

import '../constants/colors_used.dart';

class EntryContainer extends StatelessWidget {
  final List<Widget> children;

  const EntryContainer({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return
       Container(
        decoration: BoxDecoration(
          color:AppColors.bodyFillColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),

    );
  }
}