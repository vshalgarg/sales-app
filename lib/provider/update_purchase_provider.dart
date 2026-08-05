import 'dart:io';

import 'package:flutter/material.dart';

import '../model_classes/purchases/update_purchase_model.dart';
import '../services/update_purchase_api.dart';

class UpdatePurchaseProvider extends ChangeNotifier {
  bool isLoading = false;

  String? successMessage;
  String? errorMessage;

  Future<bool> updatePurchaseEntry({
    required int id,
    required String date,
    required int customerId,
    required int supplierId,
    required int staffId,
    required String remarks,
    required List<String> existingImageKeys,
    required List<File> supplierImages,
  }) async {
    isLoading = true;
    successMessage = null;
    errorMessage = null;
    notifyListeners();

    try {
      final UpdatePurchaseResponse response = await updatePurchase(
        id: id,
        date: date,
        customerId: customerId,
        supplierId: supplierId,
        staffId: staffId,
        remarks: remarks,
        existingImageKeys: existingImageKeys,
        supplierImages: supplierImages,
      );

      successMessage = response.message;
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst("Exception: ", "");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    successMessage = null;
    errorMessage = null;
    notifyListeners();
  }
}