import 'package:flutter/material.dart';
import 'package:hisabio/constants/colors_used.dart';
import 'package:hisabio/constants/custom_icons.dart';
import 'package:iconsax/iconsax.dart';

class MasterContainer extends StatelessWidget {
  final double? elevation;
  final String? name;
  final String? city;
  final String? mobile;
  final String? code;
  final VoidCallback? eyeIconTap;
  final VoidCallback? trashIconTap;
  final VoidCallback? copyIconTap;
  final VoidCallback? editIconTap;

  const MasterContainer({
    super.key,
    this.elevation,
    this.name,
    this.city,
    this.mobile,
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
          // boxShadow: BoxShadow(color:Colors.black),
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: AppColors.orangeColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Text(
                          code ?? "",
                          style: TextStyle(
                            fontSize: 12,
                            color:Colors.white,
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
                          fontWeight: FontWeight.w200,
                        ),
                      ),

                    SizedBox(height: 5),
                    Row(
                      children: [
                         const Text( "City: ",
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 3,

                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 3,
                          city ?? "",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                   // SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          "Mobile: ",
                          style: TextStyle(fontSize: 13, color: Colors.black),
                        ),
                        Text(
                          mobile ?? "",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

             // VerticalDivider(color: Colors.grey.shade300, thickness: 0.5),
              Padding(
                padding: const EdgeInsets.only(),
                child: Column(
                  children: [
                  //  GestureDetector(
                    //  onTap: eyeIconTap,
                      //child: customIcon(
                        //icon: Iconsax.eye,
                        //iconColor: AppColors.primaryPurple,
                        //bgColor: AppColors.primaryPurpleLight,
                      //),
                    //),
                    SizedBox(height: 5),
                    GestureDetector(
                      onTap: trashIconTap,
                      child: customIcon(
                        icon: Iconsax.trash,
                        iconColor: AppColors.binRed,
                        bgColor: AppColors.binRedLight,
                      ),
                    ),
                    SizedBox(height: 5),
                    GestureDetector(
                      onTap: copyIconTap,
                      child: customIcon(
                        icon: Iconsax.copy,
                        iconColor: AppColors.blueDarkCopy,
                        bgColor: AppColors.blueLightCopy,
                      ),
                    ),
                    SizedBox(height: 5),
                    GestureDetector(
                      onTap: editIconTap,
                      child: customIcon(
                        icon: Iconsax.edit,
                        iconColor: AppColors.editGreen,
                        bgColor: AppColors.editGreenLight
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
