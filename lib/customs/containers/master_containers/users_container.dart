import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/constants/custom_icons.dart';
import 'package:iconsax/iconsax.dart';

class UserContainer extends StatelessWidget {
  final double? elevation;
  final String? name;
  final String? role;
  final VoidCallback? trashIconTap;
  final VoidCallback? editIconTap;

  const UserContainer({
    super.key,
    this.elevation,
    this.name,
    this.role,
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
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (role != null && role!.trim().isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColors.orangeColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 5.0,
                          right: 5,
                          bottom: 3,
                          top: 3,
                        ),
                        child: Text(
                          role!,
                          maxLines: 1,
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                    if (role != null && role!.trim().isNotEmpty)
                      const SizedBox(height: 5),
                    Text(
                      name ?? "",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              Row(
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
                  SizedBox(width: 15),
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
    );
  }
}
