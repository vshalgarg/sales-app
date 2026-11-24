
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
    String? processingButton;

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

        // Declare modes before using them in handlers.
        final bool deleteMode = isDelete;
        final bool logoutMode = isLogout;

        return StatefulBuilder(
          builder: (context, setDialogState) {

            // Close only the confirmation dialog.
            void closeDialogIfOpen() {
              if (dialogRoute?.isCurrent == true &&
                  dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            }

            // STAY / SAVE / DELETE / LOGOUT ACTION
            Future<void> handleSave() async {
              if (isProcessing) return;

              setDialogState(() {
                isProcessing = true;
                processingButton = 'save';
              });

              // Stay: show spinner and close only the dialog.
              if (onSave == null) {
                await Future.delayed(
                  const Duration(milliseconds: 400),
                );

                closeDialogIfOpen();
                return;
              }

              try {
                await onSave();

                // Close only if the dialog is still open.
                closeDialogIfOpen();
              } catch (error) {
                if (dialogContext.mounted &&
                    dialogRoute?.isCurrent == true) {
                  setDialogState(() {
                    isProcessing = false;
                    processingButton = null;
                  });
                }

                debugPrint('Dialog action failed: $error');
              }
            }

            // LEAVE / DISCARD / CANCEL ACTION
            Future<void> handleDiscard() async {
              if (isProcessing) return;

              setDialogState(() {
                isProcessing = true;
                processingButton = 'leave';
              });

              // Show spinner on the tapped button.
              await Future.delayed(
                const Duration(milliseconds: 400),
              );

              if (!dialogContext.mounted) return;

              // Close confirmation dialog first.
              closeDialogIfOpen();

              // Delete / Logout Cancel:
              // Close only the confirmation dialog.
              if (deleteMode || logoutMode) {
                return;
              }

              // Normal Leave / Discard:
              // Execute screen-level callback.
              onDiscard?.call();
            }

            // BUTTON WIDGET
            Widget buildActionButton({
              required String label,
              required VoidCallback onPressed,
              required Color backgroundColor,
              required Color textColor,
              required String buttonType,
            }) {
              final bool showSpinner =
                  isProcessing && processingButton == buttonType;

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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                    ),
                    child: showSpinner
                        ? SizedBox(
                      height: 19,
                      width: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: textColor,
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
                          // DIALOG CONTENT
                          Padding(
                            padding: const EdgeInsets.only(top: 35),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                45,
                                16,
                                16,
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
                                        // CANCEL BUTTON
                                        buildActionButton(
                                          label: discardButtonText ?? "Cancel",
                                          onPressed: handleDiscard,
                                          buttonType: 'leave',
                                          backgroundColor:
                                          AppColors.lightGrey,
                                          textColor: Colors.black,
                                        ),

                                        const SizedBox(width: 12),

                                        // DELETE / LOGOUT BUTTON
                                        buildActionButton(
                                          label: saveButtonText ??
                                              (deleteMode
                                                  ? "Delete"
                                                  : "Logout"),
                                          onPressed: handleSave,
                                          buttonType: 'save',
                                          backgroundColor: AppColors.blue,
                                          textColor: Colors.white,
                                        ),
                                      ] else ...[
                                        // STAY BUTTON
                                        buildActionButton(
                                          label: saveButtonText ??
                                              "Save & Exit",
                                          onPressed: handleSave,
                                          buttonType: 'save',
                                          backgroundColor:
                                          AppColors.lightGrey,
                                          textColor: Colors.black,
                                        ),

                                        const SizedBox(width: 12),

                                        // LEAVE BUTTON
                                        buildActionButton(
                                          label: discardButtonText ??
                                              "Discard",
                                          onPressed: handleDiscard,
                                          buttonType: 'leave',
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

                          // TOP ICON
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
