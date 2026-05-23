import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/constants/custom_icons.dart';
import 'package:iconsax/iconsax.dart';

class SupplierContainer extends StatelessWidget {
  final double? elevation;
  final String? name;
  final String? city;
  final String? gst;
  final String? code;
  final VoidCallback? eyeIconTap;
  final VoidCallback? trashIconTap;
  final VoidCallback? copyIconTap;
  final VoidCallback? editIconTap;

  const SupplierContainer({
    super.key,
    this.elevation,
    this.name,
    this.city,
    this.gst,
    this.code,
    this.eyeIconTap,
     this.trashIconTap,
    this.copyIconTap,
     this.editIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      // shadowColor: Colors.black12,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: AppColors.primaryPurple, width: 4),
          ),
          // boxShadow: BoxShadow(color:Colors.black),
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name ?? "",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      SizedBox(height: 5),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: AppColors.primaryPurpleLight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            code ?? "",
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Expanded(
                        child: Row(
                          children: [
                            Text(overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              maxLines: 3,
                              "GST:",
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                            Text(overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              maxLines: 3,
                              gst ?? "",
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primaryPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            "City:",
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          Text(
                            city ?? "",
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                VerticalDivider(color: Colors.grey.shade300, thickness: 0.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: eyeIconTap,
                      child: customIcon(
                        icon: Iconsax.eye,
                        iconColor: AppColors.primaryPurple,
                        bgColor: AppColors.primaryPurpleLight,
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: trashIconTap,
                      child: customIcon(
                        icon: Iconsax.trash,
                        iconColor: Color(0xFFFF4D4F),
                        bgColor: Color(0xFFFFE9E9),
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: copyIconTap,
                      child: customIcon(
                        icon: Iconsax.copy,
                        iconColor: Color(0xFF2F80ED),
                        bgColor: Color(0xFFEAF2FF),
                      ),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: editIconTap,
                      child: customIcon(
                        icon: Iconsax.edit,
                        iconColor: Color(0xFF00B894),
                        bgColor: Color(0xFFE6FAF5),
                      ),
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
