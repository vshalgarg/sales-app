import 'package:flutter/material.dart';

class ExitConfirmationDialog {
  static Future<void> show(
      BuildContext context, {
        VoidCallback? onSave,
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
     // transitionDuration: const Duration(milliseconds: 250),
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
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      35,
                      20,
                      60,//40
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      bodyText ?? "Do you want to save your progress before exiting?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
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
                      height: 40,
                      width: 40,
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
                  bottom: 0 ,//-50,
                  left: 30,
                  right: 30,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff00A86B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            elevation: 5,
                          ),
                          child: Text(saveButtonText??
                            "Save & Exit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: onDiscard,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            elevation: 5,
                          ),
                          child: Text( discardButtonText??
                            "Discard",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
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