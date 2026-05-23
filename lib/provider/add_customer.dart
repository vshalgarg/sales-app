import 'package:flutter/material.dart';
import 'package:hisabio/model_classes/add_customer.dart';

import '../services/add_newcustomer_api.dart';

class AddCustomerProvider extends ChangeNotifier {

  final AddNewCustomerApi _api = AddNewCustomerApi();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AddCustomer? _response;
  AddCustomer? get response => _response;

  String? _error;
  String? get error => _error;
  String? _message;
  String? get message => _message;


  Future<void> addCustomer(Map<String, dynamic> body) async {

    _isLoading = true;
    _error = null;
    _message = null;
    notifyListeners();

    try {
      final result = await _api.addNewCustomer(body);
      _response = result;
      _message = result.message;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}