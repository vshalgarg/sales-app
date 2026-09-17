import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../constants/colors_used.dart';

class ExitConfirmationDialog {
  static Future<void> show(
    BuildContext context, {
    Future<void> Function()? onSave,
    VoidCallback? onDiscard,
    final Widget? body,
    String? bodyText,
    String? saveButtonText,
    String? discardButtonText,
    IconData? icon,
    Color? iconColor,
    bool isLogout = false,
    bool isDelete = false,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Exit Dialog",
      pageBuilder: (_, _, _) {
        return Material(
          color: Colors.black.withValues(alpha: 0.35),
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final dialogWidth = constraints.maxWidth * 0.85;

                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: dialogWidth,
                      height: 130,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child:
                            body ??
                            Text(
                              bodyText ??
                                  "Do you want to save your progress before exiting?",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                      ),
                    ),

                    Positioned(
                      bottom: -22,
                      child: Row(
                        children: [
                          // DELETE POPUP
                          if (isDelete) ...[
                            SizedBox(
                              width: 125,
                              child: ElevatedButton(
                                onPressed: onDiscard,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(125, 45),
                                  backgroundColor: AppColors.lightGrey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Text(
                                  discardButtonText ?? "Cancel",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            SizedBox(
                              width: 125,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (onSave != null) {
                                    await onSave();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(125, 45),
                                  backgroundColor: AppColors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Text(
                                  saveButtonText ?? "Delete",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),

                            // LOGOUT POPUP
                          ] else if (isLogout) ...[
                            SizedBox(
                              width: 125,
                              child: ElevatedButton(
                                onPressed: onDiscard,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(125, 45),
                                  backgroundColor: AppColors.lightGrey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Text(
                                  discardButtonText ?? "Cancel",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            SizedBox(
                              width: 125,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (onSave != null) {
                                    await onSave();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(125, 45),
                                  backgroundColor: AppColors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Text(
                                  saveButtonText ?? "Logout",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            SizedBox(
                              width: 125,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (onSave != null) {
                                    await onSave();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(125, 45),
                                  backgroundColor: AppColors.lightGrey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Text(
                                  saveButtonText ?? "Save & Exit",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            SizedBox(
                              width: 125,
                              child: ElevatedButton(
                                onPressed: onDiscard,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(125, 45),
                                  backgroundColor: AppColors.blue,
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
                        ],
                      ),
                    ),

                    Positioned(
                      top: -35,
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF3F0FF),
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Icon(
                          icon ?? Iconsax.trash,
                          color: iconColor ?? AppColors.binRed,
                          size: 35,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
