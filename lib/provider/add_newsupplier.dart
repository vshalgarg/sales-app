import 'package:flutter/material.dart';
import 'package:hisabio/model_classes/add_newsupplier.dart';
import 'package:hisabio/services/add_newsupplier_api.dart';



class AddSupplierProvider extends ChangeNotifier {
  final AddNewSupplierApiApi _api = AddNewSupplierApiApi();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  AddNewsupplier? _response;
  AddNewsupplier? get response => _response;

  Future<void> addSupplier(Map<String, dynamic> body) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _api.addNewSupplier(body);

      _response = result;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}