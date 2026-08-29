import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../constants/colors_used.dart';
import '../constants/custom_icons.dart';

class ReportField {
  final String label;
  final String value;
  final IconData? icon;

  const ReportField({required this.label, required this.value, this.icon});
}

class ReportChip {
  final IconData icon;
  final String text;

  const ReportChip({required this.icon, required this.text});
}

class ReportingCard extends StatelessWidget {
  final IconData? leadingIcon;

  final String? title;
  final String? value;

  final List<ReportChip> chips;
  final List<ReportField> fields;

  final String? amount;
  final bool deleteWithAmount;
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
    this.deleteWithAmount=false,
    this.showHeader = true,
  });

  static const primary = Color(0xff4A4CCB);
  String _formatDisplayDate(String value) {
    if (value.trim().isEmpty) return value;

    try {
      final parsedDate = DateTime.parse(value);
      return DateFormat("dd-MM-yyyy").format(parsedDate);
    } catch (_) {
      return value;
    }
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 1.8,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(leadingIcon, size: 24, color: primary),

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

                          Expanded(
                            child: Text(
                              value!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (showHeader && onEdit != null)
                      _actionButton(
                        icon: Iconsax.edit,
                        color: const Color(0xff00B894),
                        onTap: onEdit!,
                      ),
                  ],
                ),

              if (chips.isNotEmpty) ...[
                if (showHeader) const SizedBox(height: 5),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: chips
                            .map(
                              (chip) => Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: AppColors.primaryPurpleLight,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(chip.icon, size: 17, color: primary),
                                    const SizedBox(width: 2),
                                    Text(
                                      chip.icon == Iconsax.calendar
                                          ? _formatDisplayDate(chip.text)
                                          : chip.text,
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
                    ),

                    if (!showHeader && onEdit != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _actionButton(
                          icon: Iconsax.edit,
                          color: const Color(0xff00B894),
                          onTap: onEdit!,
                        ),
                      ),
                  ],
                ),
              ],

              if (fields.isNotEmpty) ...[
                const SizedBox(height: 5),

                Divider(color: Colors.grey.shade300),

                const SizedBox(height: 5),
                ...fields.asMap().entries.map((entry) {
                  final index = entry.key;
                  final field = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
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

                        if (index == fields.length - 1 && onDelete != null&&
                            !deleteWithAmount)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _actionButton(
                              icon: Iconsax.trash,
                              color: const Color(0xffFF3B30),
                              onTap: onDelete!,
                            ),
                          ),
                      ],
                    ),
                  );
                }),

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
                      if (deleteWithAmount && onDelete != null) ...[
                        const SizedBox(width: 8),
                        _actionButton(
                          icon: Iconsax.trash,
                          color: const Color(0xffFF3B30),
                          onTap: onDelete!,
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ],
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
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Center(
        child: customIcon(icon: icon, iconColor: color, bgColor: color),
      ),
    );
  }
}
