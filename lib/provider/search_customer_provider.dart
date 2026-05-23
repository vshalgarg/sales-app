import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hisabio/model_classes/search_customer_model.dart';

import '../services/search_customer.dart';

class SearchCustomerProvider extends ChangeNotifier {

  final GetSearchCustomersApi _api =
  GetSearchCustomersApi();

  SearchCustomerModel? _searchResult;

  SearchCustomerModel? get searchResult =>
      _searchResult;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _error;

  String? get error => _error;

  Timer? _debounce;

  /// SEARCH WITH DEBOUNCE
  void searchCustomer(String keyword) {

    /// cancel previous timer
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    /// new timer
    _debounce = Timer(
      const Duration(milliseconds: 500),

          () async {

        if (keyword.trim().isEmpty) {

          _searchResult = null;
          notifyListeners();
          return;
        }

        _isLoading = true;
        _error = null;

        notifyListeners();

        try {

          final result =
          await _api.getSearchCustomer(keyword);

          _searchResult = result;

        } catch (e) {

          _error = e.toString();
        }

        _isLoading = false;

        notifyListeners();
      },
    );
  }

  /// CLEAR SEARCH
  void clearSearch() {

    _searchResult = null;
    _error = null;

    notifyListeners();
  }

  @override
  void dispose() {

    _debounce?.cancel();

    super.dispose();
  }
}