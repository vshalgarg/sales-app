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
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mode == FormMode.add || mode == FormMode.edit)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  minimumSize: const Size(double.infinity, 44),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: mode == FormMode.add ? saveSupplier : update,
                child: Text(
                  mode == FormMode.add ? "Save Details" : "Update",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
