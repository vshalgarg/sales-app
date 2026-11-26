
import 'package:flutter/material.dart';
import 'package:hisabio/constants/app_spacing.dart';
import 'package:hisabio/constants/custom_icons.dart';

class CardActionItem {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const CardActionItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });
}

class CardActionPanel extends StatelessWidget {
  final List<CardActionItem> actions;
  final Color dividerColor;

  const CardActionPanel({
    super.key,
    required this.actions,
    this.dividerColor = const Color(0xff4A4CCB),
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 1,
            color: dividerColor.withOpacity(0.35),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: actions.map((action) {
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: action.onTap,
                child: customIcon(
                  icon: action.icon,
                  iconColor: action.iconColor,
                  bgColor: action.bgColor,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
