import 'package:flutter/material.dart';
import 'package:hisabio/model_classes/get_suppliers_byid.dart';
import 'package:hisabio/services/get_suppliers_byid.dart';

class GetSupplierByIdProvider extends ChangeNotifier {
  final GetSuppliersByIdApi api = GetSuppliersByIdApi();

  GetSupplierByIdModel? supplier;
  bool isLoading = false;
  String? error;

  Future<void> fetchSupplierById(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await api.getSupplierById(id);
      supplier = response;
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  void clear() {
    supplier = null;
    error = null;
    isLoading = false;
    notifyListeners();
  }
}