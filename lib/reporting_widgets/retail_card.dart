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
    const primary = Color(0xff4A4CCB);

    final date = fields.firstWhere(
          (e) => e.key.toLowerCase() == "date",
      orElse: () => const MapEntry("", ""),
    );

    final otherFields = fields
        .where((e) => e.key.toLowerCase() != "date")
        .toList();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Card(
        elevation: 1.8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // LEFT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // DATE CHIP
                      if (date.value.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(5
                          ),
                          decoration: BoxDecoration(
                            color:Colors.deepOrange[50],
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

                              const SizedBox(width: 5),

                              Text(
                                date.value,
                                style: const TextStyle(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 10),

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
                          padding: const EdgeInsets.only(bottom: 10),
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

                              const SizedBox(width: 5),

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

                              const SizedBox(width: 10),

                              Expanded(
                                child: Text(
                                  field.value
                                      .trim()
                                      .isEmpty
                                      ? "-"
                                      : field.value,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(width: 5),

                Container(
                  width: 1,
                  color: const Color(0xffECECF7),
                ),

                const SizedBox(width: 5),

                // RIGHT SIDE
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [

                    _actionButton(
                      icon: Iconsax.add_circle,
                      color: const Color(0xff3CB44B),
                      onTap: onAdd ?? () {},
                    ),

                    const SizedBox(height: 5),

                    _actionButton(
                      icon: Iconsax.edit,
                      color: const Color(0xff00B894),
                      onTap: onEdit ?? () {},
                    ),

                    const SizedBox(height: 5),

                    _actionButton(
                      icon: Iconsax.trash,
                      color: const Color(0xffFF3B30),
                      onTap: onDelete ?? () {},
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
         // height: 52,
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