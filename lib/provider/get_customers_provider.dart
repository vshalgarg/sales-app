import 'package:flutter/material.dart';
import '../services/get_customers.dart';

class CustomersProvider extends ChangeNotifier {
  final GetCustomersApi _api = GetCustomersApi();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<dynamic> _customers = [];
  List<dynamic> get customers => _customers;

  String? _error;
  String? get error => _error;

  Future<void> fetchCustomers() async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final response = await _api.getCustomers();
      _customers = response['content'] ?? [];

    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}