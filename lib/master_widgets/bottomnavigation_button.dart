import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';

import '../enums/customer_mode.dart';

class BottomNavigationButton extends StatelessWidget {
  final VoidCallback saveSupplier;
  final VoidCallback update;
  final FormMode? mode;

  const BottomNavigationButton({
    super.key,
    required this.saveSupplier,
    required this.update,
    this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left:15,right:15,bottom:30),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mode == FormMode.add) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: saveSupplier,
                child: const Text(
                  "Save Details",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
          if (mode == FormMode.edit) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: update,
                child: const Text(
                  "Update",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height:20)
          ],

        ],
      ),
    );
  }
}
