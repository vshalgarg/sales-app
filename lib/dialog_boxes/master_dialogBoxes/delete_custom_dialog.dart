import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';

class CustomDeleteDialog extends StatelessWidget {

  final String name;
  final VoidCallback onDelete;
  final String dialogBoxName;

  const CustomDeleteDialog({
    super.key,
    required this.dialogBoxName,
    required this.name,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text(
             " $dialogBoxName",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),
            Text(
              "Are you sure you want to permanently "
                  "delete $name? "
                  "This action cannot be undone.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Cancel",
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                      ),
                      onPressed: onDelete,
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                          color: Colors.white,
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