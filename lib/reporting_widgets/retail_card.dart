import 'package:flutter/material.dart';
import 'package:hisabio/constants/app_spacing.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../constants/colors_used.dart';
import '../constants/custom_icons.dart';
import '../customs/card_action_panel.dart';

class RetailCard extends StatelessWidget {
  final List<MapEntry<String, String>> fields;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  const RetailCard({
    super.key,
    required this.fields,
    this.onEdit,
    this.onAdd,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = AppColors.primaryPurple;

    final date = fields.firstWhere(
          (e) => e.key.toLowerCase() == "date",
      orElse: () => const MapEntry("", ""),
    );

    final otherFields = fields
        .where((e) => e.key.toLowerCase() != "date")
        .toList();

    String displayDate = date.value;

    if (date.value.isNotEmpty) {
      try {
        final parsedDate = DateTime.parse(date.value);
        displayDate = DateFormat("dd-MM-yyyy").format(parsedDate);
      } catch (_) {
        displayDate = date.value;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      child: Card(
        margin: const EdgeInsets.symmetric(
          vertical: AppSpacing.cardGap / 2,
        ),
        color: Colors.white,
        elevation: 1.8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
        child: Padding(
          padding: AppSpacing.card,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (date.value.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.deepOrange[50],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Iconsax.calendar,
                                size: 16,
                                color: Colors.deepOrange,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                displayDate,
                                style: const TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      ...otherFields.map((field) {
                        IconData icon = Iconsax.document;

                        switch (field.key.toLowerCase()) {
                          case "retailer":
                            icon = Iconsax.shop;
                            break;
                          case "referred by":
                            icon = Iconsax.profile_2user;
                            break;
                          case "staff":
                            icon = Iconsax.user;
                            break;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.md,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 18,
                                decoration: const BoxDecoration(
                                  color: Color(0xffF3F2FF),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  icon,
                                  size: 18,
                                  color: primary,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              SizedBox(
                                width: 90,
                                child: Text(
                                  field.key,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 8,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  field.value.trim().isEmpty
                                      ? "-"
                                      : field.value,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  width: 1,
                  color: const Color(0xffECECF7),
                ),
                const SizedBox(width: AppSpacing.xs),
                Center(
                  child: CardActionPanel(
                    actions: [
                      if (onAdd != null)
                        CardActionItem(
                          icon: Iconsax.add_circle,
                          iconColor: AppColors.editGreen,
                          bgColor: AppColors.editGreenLight,
                          onTap: onAdd!,
                        ),

                      if (onEdit != null)
                        CardActionItem(
                          icon: Iconsax.edit,
                          iconColor: AppColors.editGreen,
                          bgColor: AppColors.editGreenLight,
                          onTap: onEdit!,
                        ),

                      if (onDelete != null)
                        CardActionItem(
                          icon: Iconsax.trash,
                          iconColor: AppColors.binRed,
                          bgColor: AppColors.binRedLight,
                          onTap: onDelete!,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          child: Center(
            child: customIcon(
              icon: icon,
              iconColor: color,
              bgColor: color,
            ),
          ),
        ),
      ),
    );
  }
}
