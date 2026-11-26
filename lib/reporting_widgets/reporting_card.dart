
import 'package:flutter/material.dart';
import 'package:hisabio/constants/app_spacing.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../constants/colors_used.dart';
import '../customs/card_action_panel.dart';

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

  // Kept for compatibility with existing screen calls.
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
    this.deleteWithAmount = false,
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

  List<CardActionItem> _buildActions() {
    return [
      if (onEdit != null)
        CardActionItem(
          icon: Iconsax.edit,
          iconColor: const Color(0xff00B894),
          bgColor: const Color(0xff00B894),
          onTap: onEdit!,
        ),
      if (onDelete != null)
        CardActionItem(
          icon: Iconsax.trash,
          iconColor: const Color(0xffFF4D4F),
          bgColor: const Color(0xffFF4D4F),
          onTap: onDelete!,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final actions = _buildActions();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      child: Card(
        margin: const EdgeInsets.symmetric(
          vertical: AppSpacing.cardGap / 2,
        ),
        elevation: 1.8,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
        ),
        child: Padding(
          padding: AppSpacing.card,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showHeader) _buildHeader(),

                      if (chips.isNotEmpty) ...[
                        if (showHeader)
                          const SizedBox(height: AppSpacing.xs),
                        _buildChips(),
                      ],

                      if (fields.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Divider(color: Colors.grey.shade300),
                        const SizedBox(height: AppSpacing.xs),
                        _buildFields(),

                        if (amount != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          _buildAmount(),
                        ],
                      ],
                    ],
                  ),
                ),

                // Right-side actions
                if (actions.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.sm),
                  CardActionPanel(
                    actions: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          leadingIcon,
          size: 24,
          color: primary,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              if (value != null)
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
      ],
    );
  }

  Widget _buildChips() {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: chips.map((chip) {
        return Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
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
        );
      }).toList(),
    );
  }

  Widget _buildFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields.map((field) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: AppSpacing.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                field.icon ?? Icons.circle,
                size: 18,
                color: primary,
              ),
              const SizedBox(width: AppSpacing.xs),
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
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmount() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
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
    );
  }
}
