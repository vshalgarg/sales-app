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
    this.onDelete,
    this.onTap,
    this.onAdd,
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            children: List.generate(fields.length, (index) {
              final field = fields[index];

              return SizedBox(
                height: 38,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Expanded(
                    //   child: Row(
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: [
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
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),

                    SizedBox(
                      width: 40,
                      child: Align(
                        alignment: Alignment.center,
                      child: index == 0
                          ? _actionButton(
                              icon: Iconsax.edit,
                              color: const Color(0xFF00B894),
                              onTap: onEdit ?? () {},
                            )
                          : index == fields.length - 1
                          ? _actionButton(
                              icon: Iconsax.trash,
                              color: const Color(0xFFFF3B30),
                              onTap: onDelete ?? () {},
                            )
                          : const SizedBox(),
                    ),
                    )
                  ],
                ),
              );
            }),
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
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Center(
          child: customIcon(
              icon: icon,
              iconColor: color,
              bgColor: color
          ),
        ),
      ),
    );
  }
}
