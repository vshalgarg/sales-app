import 'package:flutter/material.dart';
import '../model_classes/purchases/get_purchase_model.dart';
import '../services/purchase_details_api.dart';

class GetPurchaseProvider extends ChangeNotifier {
  bool isLoading = false;

  String? successMessage;
  String? errorMessage;

  PurchaseDetails? purchaseDetails;
  String? detailsMessage;
  bool isDetailsLoading = false;

  Future<bool> fetchPurchaseDetails(int id) async {
    isDetailsLoading = true;
    isLoading = true;

    purchaseDetails = null;
    successMessage = null;
    errorMessage = null;
    detailsMessage = null;

    notifyListeners();

    try {
      final response = await getPurchaseDetails(id);

      detailsMessage = response.message;

      if (response.success && response.data != null) {
        purchaseDetails = response.data;
        successMessage = response.message;
        return true;
      } else {
        errorMessage = response.message;
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      detailsMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      isDetailsLoading = false;
      notifyListeners();
    }
  }
}