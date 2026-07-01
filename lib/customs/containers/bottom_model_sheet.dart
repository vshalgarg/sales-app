import 'package:flutter/material.dart';

import '../../constants/colors_used.dart';

class CustomBottomSheet extends StatelessWidget {
  final Widget content;
  final VoidCallback? onApply;
  final VoidCallback? onClear;

  const CustomBottomSheet({
    super.key,

    required this.content,
    this.onApply,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 35,
              child: Icon(
                Icons.filter_alt_outlined,
                color: AppColors.primaryPurple,
                size: 28,
              ),
            ),

            const SizedBox(height: 16),
            Text(
              "Apply Filters",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryPurple,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            content,

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    child: OutlinedButton.icon(
                      onPressed: onClear,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Clear Filters"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryPurple,
                        side: const BorderSide(
                          color: AppColors.primaryPurple,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: SizedBox(
                    child: ElevatedButton.icon(
                      onPressed: onApply,
                      icon: const Icon(Icons.filter_alt_outlined),
                      label: const Text("Apply Filters"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}