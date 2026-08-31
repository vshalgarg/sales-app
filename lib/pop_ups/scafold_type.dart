import 'package:flutter/material.dart';

class ScaffoldSnackBar {
  static OverlayEntry? _currentEntry;

  static void show(
      BuildContext context,
      String message,
      ) {
    if (!context.mounted) return;

    final lower = message.toLowerCase();

    final isError =
        lower.contains("fill") ||
            lower.contains("at least") ||
            lower.contains("do not match") ||
            lower.contains("enter") ||
            lower.contains("invalid") ||
            lower.contains("error") ||
            lower.contains("failed") ||
            lower.contains("already") ||
            lower.contains("required");

    // Remove previous message
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        final topPadding = MediaQuery.of(context).padding.top;

        return Positioned(
          top: topPadding,
          left: 20,
          right: 20,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              color: isError ? Colors.red : Colors.green,
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 14,
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );

    _currentEntry = entry;
    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      if (entry.mounted) {
        entry.remove();
      }

      if (_currentEntry == entry) {
        _currentEntry = null;
      }
    });
  }
}