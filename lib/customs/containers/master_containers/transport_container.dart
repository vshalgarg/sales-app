import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/constants/custom_icons.dart';
import 'package:iconsax/iconsax.dart';

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
      elevation: elevation,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(15),
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
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            status ?? "",
                            style: TextStyle(
                              color: AppColors.editGreen,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        name ?? "",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.primaryPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            " Phone :   ",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            phone!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Expanded(
                        child: Row(
                          children: [
                            const Text(
                              " GST :  ",
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              maxLines: 3,

                              style: TextStyle(
                                fontSize: 13,
                                fontWeight:FontWeight.w600 ,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              maxLines: 3,
                              gst ?? "",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            " City :  ",
                            style: TextStyle(fontSize: 13,
                                fontWeight:FontWeight.w600 ,
                                color: Colors.black),
                          ),
                          Text(
                            city ?? "",
                            style: TextStyle(fontSize: 13, color: Colors.black),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: trashIconTap,
                      child: customIcon(
                        icon: Iconsax.trash,
                        iconColor: AppColors.binRed,
                        bgColor: AppColors.binRedLight,
                      ),
                    ),
                   // SizedBox(width: 10),
                    GestureDetector(
                      onTap: copyIconTap,
                      child: customIcon(
                        icon: Iconsax.copy,
                        iconColor: AppColors.blueDarkCopy,
                        bgColor: AppColors.blueLightCopy,
                      ),
                    ),
                    //SizedBox(width: 10),
                    GestureDetector(
                      onTap: editIconTap,
                      child: customIcon(
                        icon: Iconsax.edit,
                        iconColor: AppColors.editGreen,
                        bgColor: AppColors.editGreenLight,
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
