import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/enums/supplier_mode.dart';

class BottomNavigationButton extends StatelessWidget {
  final VoidCallback saveSupplier;
  final VoidCallback saveAndAddNew;
  final VoidCallback cancel;
  final VoidCallback update;
  final SupplierMode? mode;

  const BottomNavigationButton({
    super.key,
    required this.saveSupplier,
    required this.saveAndAddNew,
    required this.cancel,
    required this.update,
    this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if(mode==SupplierMode.add)...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: saveSupplier,
              child: const Text(
                "Save Details",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),],
          if(mode==SupplierMode.edit)...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: update,
              child: const Text(
                "Update",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),],
          //SizedBox(height: 10),
if(mode==SupplierMode.add)...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: saveAndAddNew,
              child: const Text(
                "Save & Add New",
                style: TextStyle(color: AppColors.primaryPurple),
              ),
            ),
          ),],

          SizedBox(height: 10),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: cancel,
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
