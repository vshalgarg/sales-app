import 'package:flutter/material.dart';
import '../constants/colors_used.dart';

Widget menuItemCard({
  required String imagePath,
  required String title,
  required VoidCallback onTap,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
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
            width: 56,
            height: 56,
            fit: BoxFit.contain,
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        title,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          height: 1.1,
        ),
      ),
    ],
  );
}
