import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';

class BottomNavigationButton extends StatelessWidget {
  final VoidCallback saveSupplier;
  final VoidCallback saveAndAddNew;
  final VoidCallback cancel;
  const BottomNavigationButton({super.key,required this.saveSupplier,required this.saveAndAddNew,required this.cancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width:double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: saveSupplier,
              child: const Text("Save Supplier",style:TextStyle(color:Colors.white)),
            ),
          ),

          SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
              onPressed: saveAndAddNew,
              child: const Text("Save & Add New",style:TextStyle(color:AppColors.primaryPurple)),
            ),
          ),

          SizedBox(height: 10),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed:cancel,
              child: const Text("Cancel",style:TextStyle(color:Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}
