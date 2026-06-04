import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/constants/custom_icons.dart';
import 'package:iconsax/iconsax.dart';

class UserContainer extends StatelessWidget {
  final double? elevation;
  final String? name;
  final VoidCallback? trashIconTap;
  final VoidCallback? editIconTap;

  const UserContainer({
    super.key,
    this.elevation,
    this.name,
    this.trashIconTap,
    this.editIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.primaryPurple, width: 4),
          ),
          // boxShadow: BoxShadow(color:Colors.black),
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name ?? "",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      SizedBox(height: 5),
                      Expanded(
                        child: Row(
                          children: [


                          ],
                        ),
                      ),

                    ],
                  ),
                ),

                VerticalDivider(color: Colors.grey.shade300, thickness: 0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: trashIconTap,
                      child: customIcon(
                        icon: Iconsax.trash,
                        iconColor: AppColors.binRed,
                        bgColor: AppColors.binRedLight,
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: editIconTap,
                      child: customIcon(
                        icon: Iconsax.edit,
                        iconColor: AppColors.editGreen,
                        bgColor: AppColors.editGreenLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
