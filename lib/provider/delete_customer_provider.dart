import 'package:flutter/material.dart';
import '../model_classes/delete_customer_model.dart';
import '../services/delete_customer.dart';

class DeleteCustomerProvider extends ChangeNotifier {
  final DeleteCustomerApi _api = DeleteCustomerApi();

  bool _isLoading = false;
  String? _errorMessage;
  DeleteCustomerModel? _deleteCustomerModel;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DeleteCustomerModel? get deleteCustomerModel => _deleteCustomerModel;

  Future<void> deleteCustomer(Map<String, dynamic> body) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.deleteCustomer(body);
      _deleteCustomerModel = response;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}