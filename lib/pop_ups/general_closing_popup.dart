import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../constants/colors_used.dart';

class ExitConfirmationDialog {
  static Future<void> show(
      BuildContext context, {
        Future<void> Function()? onSave,
        VoidCallback? onDiscard,
       // VoidCallback? onClose,
        final Widget? body,
        String? bodyText,
        String? saveButtonText,
        String?discardButtonText,
        IconData? icon,
        Color? iconColor,
      }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Exit Dialog",
      pageBuilder: (_, __, ___) {
        return Material(
          color: Colors.black.withOpacity(0.35),
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,

              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: body ??
                        Text(
                          bodyText ?? "Do you want to save your progress before exiting?",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 0 ,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 130,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (onSave != null) {
                              await onSave();
                            }

                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(120, 45),
                            backgroundColor: const Color(0xff00A86B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(
                            saveButtonText ?? "Save & Exit",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      SizedBox(
                        width: 130,
                        child: ElevatedButton(
                          onPressed: onDiscard,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(120, 45),
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(
                            discardButtonText ?? "Discard",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ),
                Positioned(
                  top:-25,
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF3F0FF),
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                    ),
                    child: Icon(
                      icon ?? Iconsax.trash,
                      color: iconColor ?? AppColors.binRed,
                      size: 35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}