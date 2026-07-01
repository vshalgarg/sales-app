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
                  child: Column(mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name ?? "",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w200,
                        ),
                      ),

                    ],
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: trashIconTap,
                      child: customIcon(
                        icon: Iconsax.trash,
                        iconColor: AppColors.binRed,
                        bgColor: AppColors.binRedLight,
                      ),
                    ),
                    SizedBox(height: 10),
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
