import 'package:flutter/material.dart';
import 'package:hisabio/model_classes/get_supplier.dart';
import 'package:hisabio/services/get_suppliers.dart';

class SupplierProvider extends ChangeNotifier {

  final GetSuppliersApi _api = GetSuppliersApi();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  GetSupplier? supplierData;
  GetSupplier? get data => supplierData;

  Future<void> fetchSuppliers() async {

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {

      supplierData = await _api.getSupplier();

    } catch (e) {

      _error = e.toString();

    } finally {

      _isLoading = false;
      notifyListeners();
    }
  }
}