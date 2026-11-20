
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../constants/colors_used.dart';

class ExitConfirmationDialog {
  static Future<void> show(
      BuildContext context, {
        Future<void> Function()? onSave,
        VoidCallback? onDiscard,
        Widget? body,
        String? bodyText,
        String? saveButtonText,
        String? discardButtonText,
        IconData? icon,
        Color? iconColor,
        bool isLogout = false,
        bool isDelete = false,
      }) {
    bool isProcessing = false;

    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Exit Dialog",
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 180),

      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.95,
              end: 1.0,
            ).animate(animation),
            child: child,
          ),
        );
      },

      pageBuilder: (dialogContext, _, _) {
        final dialogRoute = ModalRoute.of(dialogContext);

        return StatefulBuilder(
          builder: (context, setDialogState) {

            // Prevent accidentally popping the screen behind the dialog.
            void closeDialogIfOpen() {
              if (dialogRoute?.isCurrent == true &&
                  dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            }

            Future<void> handleSave() async {
              if (isProcessing) return;

              if (onSave == null) {
                closeDialogIfOpen();
                return;
              }

              setDialogState(() {
                isProcessing = true;
              });

              try {
                await onSave();

                // If the callback already closed the dialog,
                // this will not pop the underlying screen.
                closeDialogIfOpen();
              } catch (error) {
                if (dialogContext.mounted &&
                    dialogRoute?.isCurrent == true) {
                  setDialogState(() {
                    isProcessing = false;
                  });
                }

                debugPrint('Dialog action failed: $error');
              }
            }

            void handleDiscard() {
              if (isProcessing) return;

              if (onDiscard != null) {
                onDiscard();
              }

              // Close only if the callback did not already close it.
              closeDialogIfOpen();
            }

            Widget buildActionButton({
              required String label,
              required VoidCallback onPressed,
              required Color backgroundColor,
              required Color textColor,
              bool isPrimary = false,
            }) {
              return Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : onPressed,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: backgroundColor,
                      foregroundColor: textColor,
                      disabledBackgroundColor:
                      backgroundColor.withValues(alpha: 0.65),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: isProcessing && isPrimary
                        ? const SizedBox(
                      height: 19,
                      width: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }

            final bool deleteMode = isDelete;
            final bool logoutMode = isLogout;

            return Material(
              color: Colors.transparent,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 45,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 400,
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          // Dialog content and buttons are inside
                          // the actual layout bounds.
                          Padding(
                            padding: const EdgeInsets.only(top: 35),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                16, 45, 16, 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  body ??
                                      Text(
                                        bodyText ??
                                            "Do you want to save your progress before exiting?",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),

                                  const SizedBox(height: 24),

                                  Row(
                                    children: [
                                      if (deleteMode || logoutMode) ...[
                                        buildActionButton(
                                          label: discardButtonText ?? "Cancel",
                                          onPressed: handleDiscard,
                                          backgroundColor:
                                          AppColors.lightGrey,
                                          textColor: Colors.black,
                                        ),

                                        const SizedBox(width: 12),

                                        buildActionButton(
                                          label: saveButtonText ??
                                              (deleteMode
                                                  ? "Delete"
                                                  : "Logout"),
                                          onPressed: handleSave,
                                          backgroundColor: AppColors.blue,
                                          textColor: Colors.white,
                                          isPrimary: true,
                                        ),
                                      ] else ...[
                                        buildActionButton(
                                          label: saveButtonText ?? "Save & Exit",
                                          onPressed: handleSave,
                                          backgroundColor:
                                          AppColors.lightGrey,
                                          textColor: Colors.black,
                                        ),

                                        const SizedBox(width: 12),

                                        buildActionButton(
                                          label: discardButtonText ?? "Discard",
                                          onPressed: handleDiscard,
                                          backgroundColor: AppColors.blue,
                                          textColor: Colors.white,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Icon remains visually above the dialog.
                          Positioned(
                            top: 0,
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
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
