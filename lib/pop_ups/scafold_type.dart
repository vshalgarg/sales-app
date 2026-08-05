import 'package:flutter/material.dart';

class ScaffoldSnackBar {
  static void show(
      BuildContext context,
      String message,
      ) {
    final lower = message.toLowerCase();

    final isError =
        lower.contains("invalid") ||
            lower.contains("error") ||
            lower.contains("failed") ||
            lower.contains("found") ||
            lower.contains("required");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}