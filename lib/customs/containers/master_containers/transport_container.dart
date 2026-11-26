
import 'package:flutter/material.dart';
import 'package:hisabio/constants/app_spacing.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/constants/custom_icons.dart';
import 'package:iconsax/iconsax.dart';

import '../../card_action_panel.dart';

class TransportContainer extends StatelessWidget {
  final double? elevation;
  final String? name;
  final String? city;
  final String? gst;
  final String? phone;
  final String? status;

  final VoidCallback? eyeIconTap;
  final VoidCallback? trashIconTap;
  final VoidCallback? copyIconTap;
  final VoidCallback? editIconTap;

  const TransportContainer({
    super.key,
    this.elevation,
    this.name,
    this.city,
    this.status,
    this.gst,
    this.phone,
    this.eyeIconTap,
    this.trashIconTap,
    this.copyIconTap,
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
        borderRadius: BorderRadius.circular(
          AppSpacing.borderRadius,
        ),
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            AppSpacing.borderRadius,
          ),
        ),
        child: IntrinsicHeight(
          child: Padding(
            padding: AppSpacing.card,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.editGreenLight,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Text(
                          status ?? "-",
                          style: const TextStyle(
                            color: AppColors.editGreen,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      Text(
                        name ?? "",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Phone : ",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              phone?.trim().isNotEmpty == true
                                  ? phone!
                                  : "-",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      Row(
                        children: [
                          const Text(
                            "GST : ",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              gst ?? "-",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      Row(
                        children: [
                          const Text(
                            "City : ",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              city ?? "-",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (trashIconTap != null ||
                    copyIconTap != null ||
                    editIconTap != null)
                  CardActionPanel(
                    actions: [
                      if (copyIconTap != null)
                        CardActionItem(
                          icon: Iconsax.copy,
                          iconColor: AppColors.blueDarkCopy,
                          bgColor: AppColors.blueLightCopy,
                          onTap: copyIconTap!,
                        ),

                      if (editIconTap != null)
                        CardActionItem(
                          icon: Iconsax.edit,
                          iconColor: AppColors.editGreen,
                          bgColor: AppColors.editGreenLight,
                          onTap: editIconTap!,
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
        ),
      ),
    );
  }
}
