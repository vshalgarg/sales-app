
import 'package:flutter/material.dart';

import 'loading_service.dart';

class GlobalLoader extends StatelessWidget {
  const GlobalLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: LoadingService.isLoading,
      builder: (context, loading, child) {
        if (!loading) return const SizedBox.shrink();

        return Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha:0.25),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF203A8F),
                strokeWidth: 3,
              ),
            ),
          ),
        );
      },
    );
  }
}
