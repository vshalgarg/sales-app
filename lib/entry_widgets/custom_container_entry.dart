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
    return Card(elevation: 1,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.primaryPurple, width: 4),
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 5),
          child: Column(mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}