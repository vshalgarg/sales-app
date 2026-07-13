import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../constants/colors_used.dart';
import '../constants/custom_icons.dart';

class ReportField {
  final String label;
  final String value;
  final IconData? icon;

  const ReportField({
    required this.label,
    required this.value,
    this.icon,
  });
}

class ReportChip {
  final IconData icon;
  final String text;

  const ReportChip({
    required this.icon,
    required this.text,
  });
}

class ReportingCard extends StatelessWidget {
  final IconData? leadingIcon;

  final String? title;
  final String? value;

  final List<ReportChip> chips;
  final List<ReportField> fields;

  final String? amount;

  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showHeader;
  const ReportingCard({
    super.key,
     this.leadingIcon,
     this.title,
     this.value,
    this.chips = const [],
    this.fields = const [],
    this.amount,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showHeader = true,
  });

  static const primary = Color(0xff4A4CCB);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Card(
            elevation: 1.8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showHeader)
                  Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Icon(
                        leadingIcon,
                        size: 24,
                        color: primary,
                      ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title!,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            value!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (onEdit != null)
                      _actionButton(
                        icon: Iconsax.edit,
                        color: const Color(0xff00B894),
                        onTap: onEdit!,
                      ),
                  ],
                ),

                if (chips.isNotEmpty) ...[
                  if (showHeader) const SizedBox(height: 5),

        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: chips
              .map(
                (chip) => Container(
              padding: const EdgeInsets.all(5
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primaryPurpleLight,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    chip.icon,
                    size: 17,
                    color: primary,
                  ),

                  const SizedBox(width:2),

                  Text(
                    chip.text,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
              .toList(),
        ),
        ],

        if (fields.isNotEmpty) ...[
    const SizedBox(height: 5),

    Divider(
    color: Colors.grey.shade300,
    ),

    const SizedBox(height: 5),
          ...fields.map(
                (field) =>
                    Padding(
              padding: const EdgeInsets.only(bottom: 5),
             child:
    Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                    Icon(
                      field.icon ?? Icons.circle,
                      size: 18,
                      color: primary,
                    ),

                  const SizedBox(width: 5),

                  SizedBox(
                    width: 80,
                    child: Text(
                      field.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      field.value.isEmpty ? "-" : field.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],

                    if (amount != null) ...[
                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xffF4FCF9),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    "Amount",
                                    style: TextStyle(
                                      color: Colors.teal,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const Spacer(),

                                  Text(
                                    "₹ $amount",
                                    style: const TextStyle(
                                      color: Colors.teal,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          if (onDelete != null)
                            _actionButton(
                              icon: Iconsax.trash,
                              color: const Color(0xffFF3B30),
                              onTap: onDelete!,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
            ),
    )
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Center(
        child: customIcon(
          icon: icon,
          iconColor: color,
          bgColor: color,
        ),
      ),
    );
  }
}