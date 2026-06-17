import 'package:flutter/material.dart';

import '../constants/colors_used.dart';

Widget menuItemCard({
  required String imagePath,
  required String title,
  required VoidCallback onTap
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      GestureDetector(onTap:onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.containerFillColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    ],
  );
}