import 'package:flutter/material.dart';
import 'package:hisabio/constants/app_spacing.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/constants/custom_icons.dart';
import 'package:iconsax/iconsax.dart';

import '../../card_action_panel.dart';

class UserContainer extends StatelessWidget {
  final double? elevation;
  final String? name;
  final String? role;
  final VoidCallback? trashIconTap;
  final VoidCallback? changePasswordTap;
  final VoidCallback? editIconTap;

  const UserContainer({
    super.key,
    this.elevation,
    this.name,
    this.role,
    this.trashIconTap,
    this.changePasswordTap,
    this.editIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: AppSpacing.cardGap / 2,
      ),
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
        padding: AppSpacing.card,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (role != null && role!.trim().isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColors.orangeColor,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 3,
                      ),
                      child: Text(
                        role!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  if (role != null && role!.trim().isNotEmpty)
                    const SizedBox(height: AppSpacing.xs),
                  Text(
                    name ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.primaryPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (trashIconTap != null ||
                changePasswordTap != null ||
                editIconTap != null)
              CardActionPanel(
                actions: [
                  if (editIconTap != null)
                    CardActionItem(
                      icon: Iconsax.edit,
                      iconColor: AppColors.editGreen,
                      bgColor: AppColors.editGreenLight,
                      onTap: editIconTap!,
                    ),

                  if (changePasswordTap != null)
                    CardActionItem(
                      icon: Iconsax.lock,
                      iconColor: AppColors.blueDarkCopy,
                      bgColor: AppColors.blueLightCopy,
                      onTap: changePasswordTap!,
                    ),

                  if (trashIconTap != null)
                    CardActionItem(
                      icon: Iconsax.trash,
                      iconColor: AppColors.binRed,
                      bgColor: AppColors.binRedLight,
                      onTap: trashIconTap!,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
