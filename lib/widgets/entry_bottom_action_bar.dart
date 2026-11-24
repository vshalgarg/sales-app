import 'package:flutter/material.dart';
import '../constants/colors_used.dart';
import 'entry_action_button.dart';

class EntryBottomActionBar extends StatelessWidget {
  final String secondaryText;
  final IconData secondaryIcon;
  final VoidCallback? onSecondaryPressed;

  final String primaryText;
  final IconData primaryIcon;
  final VoidCallback? onPrimaryPressed;

  const EntryBottomActionBar({
    super.key,
    required this.secondaryText,
    required this.secondaryIcon,
    required this.onSecondaryPressed,
    required this.primaryText,
    required this.primaryIcon,
    required this.onPrimaryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          15,
          10,
          15,
          10,
        ),
        decoration: BoxDecoration(
          color: AppColors.bodyFillColor,
        ),
        child: Row(
          children: [
            EntryActionButton(
              text: secondaryText,
              icon: secondaryIcon,
              onPressed: onSecondaryPressed,
            ),

            const SizedBox(width: 12),

            EntryActionButton(
              text: primaryText,
              icon: primaryIcon,
              onPressed: onPrimaryPressed,
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }
}