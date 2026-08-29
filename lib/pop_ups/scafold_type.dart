import 'package:flutter/material.dart';

class ScaffoldSnackBar {
  static void show(
      BuildContext context,
      String message,
      ) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final lower = message.toLowerCase();

    final isError =
        lower.contains("fill") ||
            lower.contains("at least")||
            lower.contains("do not match") ||
            lower.contains("enter") ||
            lower.contains("invalid") ||
            lower.contains("error") ||
            lower.contains("failed") ||
            lower.contains("already") ||
            lower.contains("required");

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}