import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../constants/custom_icons.dart';

class ReportingCard extends StatelessWidget {
  final List<MapEntry<String, String>> fields;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  const ReportingCard({
    super.key,
    required this.fields,
    this.onEdit,
    this.onAdd,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child:Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Left side - Fields
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: fields
                      .map(
                        (field) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              field.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              field.value.trim().isEmpty ? "-" : field.value,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .toList(),
                ),
              ),

              const SizedBox(width: 10),

              /// Right side - Icons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _actionButton(
                    icon: Iconsax.edit,
                    color: const Color(0xFF00B894),
                    onTap: onEdit ?? () {},
                  ),

                  const SizedBox(height: 8),

                  _actionButton(
                    icon: Iconsax.trash,
                    color: const Color(0xFFFF3B30),
                    onTap: onDelete ?? () {},
                  ),
                ],
              ),
            ],
          )
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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: customIcon(
            icon:icon,
            iconColor: color,
            bgColor: color,
          ),
        ),
      ),
    );
  }
}
