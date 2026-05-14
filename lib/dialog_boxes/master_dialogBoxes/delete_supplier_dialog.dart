import 'package:flutter/material.dart';

class CustomDeleteDialog extends StatelessWidget {

  final String supplierName;
  final VoidCallback onDelete;

  const CustomDeleteDialog({
    super.key,
    required this.supplierName,
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

            /// Title
            const Text(
              "Delete Supplier",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            /// Message
            Text(
              "Are you sure you want to permanently "
                  "delete $supplierName? "
                  "This action cannot be undone.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 25),

            /// Buttons
            Row(
              children: [

                /// Cancel Button
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

                /// Delete Button
                Expanded(
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
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