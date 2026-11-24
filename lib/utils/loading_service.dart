
import 'package:flutter/material.dart';

class LoadingService {
  LoadingService._();

  static int _loadingCount = 0;

  static final ValueNotifier<bool> isLoading =
  ValueNotifier<bool>(false);

  static void initialize() {
    _loadingCount = 0;
    isLoading.value = false;
  }

  static void show() {
    _loadingCount++;

    if (_loadingCount == 1) {
      isLoading.value = true;
    }

    debugPrint('GLOBAL LOADER SHOW - count: $_loadingCount');
  }

  static void hide() {
    if (_loadingCount > 0) {
      _loadingCount--;
    }

    if (_loadingCount == 0) {
      isLoading.value = false;
    }

    debugPrint('GLOBAL LOADER HIDE - count: $_loadingCount');
  }

  static void reset() {
    _loadingCount = 0;
    isLoading.value = false;
  }
}
