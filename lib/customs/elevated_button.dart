import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final Future<void> Function()? onPressed;
  final String text;
  final Color? color;
  final TextStyle? textStyle;
  final double? height;
  final double? width;
  final double borderRadius;
 // final VoidCallback onPressed;
  final IconData? icons;
  final double? iconSize;
  final Color? iconColor;

  const CustomElevatedButton({
    super.key,
    required this.text,
    this.color,
    this.textStyle,
    this.height,
    this.width,
    this.icons,
    this.iconColor,
    required this.onPressed,
    required this.borderRadius,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: Size(
          width ?? double.infinity,
          height ?? 50,
        ),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),

      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text, style: textStyle),
          if (icons != null) ...[
            Icon(icons, size: iconSize,color:iconColor),
          ],
        ],
      ),
    );
  }
}
