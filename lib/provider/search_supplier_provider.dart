import 'package:flutter/material.dart';
import 'package:hisabio/model_classes/search_supplier.dart';
import 'package:hisabio/services/search_supplier.dart';

class SearchSupplierProvider extends ChangeNotifier {

  final GetSearchSuppliersApi _api = GetSearchSuppliersApi();

  SearchSupplier? searchSupplier;

  bool isLoading = false;

  String? error;

  Future<void> searchSuppliers(String keyword) async {

    if (keyword.trim().isEmpty) {
      searchSupplier = null;
      notifyListeners();
      return;
    }

    try {

      isLoading = true;
      error = null;

      notifyListeners();

      final response = await _api.getSearchSupplier(keyword);

      searchSupplier = response;

    } catch (e) {

      error = e.toString();

    } finally {

      isLoading = false;
      notifyListeners();
    }
  }
}