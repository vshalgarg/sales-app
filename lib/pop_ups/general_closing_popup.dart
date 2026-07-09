import 'package:flutter/material.dart';

class ExitConfirmationDialog {
  static Future<void> show(
      BuildContext context, {
        Future<void> Function()? onSave,
        VoidCallback? onDiscard,
        VoidCallback? onClose,
        String? bodyText,
        String? saveButtonText,
        String?discardButtonText,
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
                    width:350,
                    height:150,
                    padding: const EdgeInsets.all(50),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      bodyText ?? "Do you want to save your progress before exiting?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: onClose,
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 25,
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
                        width: 130, // Change as needed
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
              ],
            ),
          ),
        );
      },
    );
  }
}