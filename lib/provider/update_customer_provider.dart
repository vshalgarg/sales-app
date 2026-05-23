import 'package:flutter/material.dart';
import '../model_classes/update_customer_model.dart';
import '../services/update_customer_api.dart';

class UpdateCustomerProvider extends ChangeNotifier {
  final UpdateCustomerApi _api = UpdateCustomerApi();

  bool _isLoading = false;
  String? _errorMessage;
  UpdateCustomerModel? _updateCustomerResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UpdateCustomerModel? get updateCustomerResponse =>
      _updateCustomerResponse;

  Future<void> updateCustomer({
    required Map<String, dynamic> body,
    required int id,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _api.updateCustomer(
        body: body,
        id: id,
      );

      _updateCustomerResponse = response;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearData() {
    _updateCustomerResponse = null;
    _errorMessage = null;
    notifyListeners();
  }
}