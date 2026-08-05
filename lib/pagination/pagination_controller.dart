import 'package:flutter/material.dart';

enum SwipeDirection {
  left,
  right,
  none,
}

class PaginationController extends ChangeNotifier {
  bool _loading = false;

  SwipeDirection _direction = SwipeDirection.none;

  SwipeDirection get direction => _direction;

  bool get loading => _loading;

  Future<void> execute({
    required SwipeDirection direction,
    required Future<void> Function() callback,
  }) async {
    if (_loading) return;

    _loading = true;
    _direction = direction;
    notifyListeners();

    try {
      await callback();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void resetDirection() {
    _direction = SwipeDirection.none;
  }
}