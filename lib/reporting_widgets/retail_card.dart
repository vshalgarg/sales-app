import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../constants/colors_used.dart';
import '../constants/custom_icons.dart';

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
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side - Fields
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: fields.map((field) {
                    final isDate = field.key.toLowerCase() == "date";

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: isDate
                          ? Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: AppColors.orangeColor,
                            ),
                    child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                              field.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                    )
                     ]
                      )
                          : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              field.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            child:Text(
                              field.value.trim().isEmpty ? "-" : field.value,
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(width: 8),

              // Right side - Action Icons
              Column(
                children: [
                  const SizedBox(height: 34),
                  _actionButton(
                    icon: Iconsax.add_circle,
                    color: const Color(0xFF3CB44B),
                    onTap: onAdd ?? () {},
                  ),
                  const SizedBox(height: 8),
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
          ),
        ),
    ));
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
