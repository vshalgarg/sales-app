import 'package:flutter/material.dart';
import 'package:hisabio/model_classes/get_supplier.dart';
import 'package:hisabio/services/get_suppliers.dart';

class SupplierProvider extends ChangeNotifier {
  final GetSuppliersApi _api = GetSuppliersApi();

  final List<Content> suppliers = [];

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;

  int _page = 0;
  final int _size = 10;

  String? error;

  Future<void> fetchSuppliers({bool refresh = false}) async {
    if (isLoading || isLoadingMore) return;


    if (refresh) {
      _page = 0;
      suppliers.clear();
      hasMore = true;
      error = null;
    }

    if (!hasMore) return;

    if (_page == 0) {
      isLoading = true;
    } else {
      isLoadingMore = true;
    }

    notifyListeners();

    try {
      final response = await _api.getSupplier(
        page: _page,
        size: _size,
      );
      final List<Content> newSuppliers = response.content ?? [];

      for (final s in response.content ?? []) {
      }

      suppliers.addAll(newSuppliers);


      hasMore = !(response.last ?? true);

      if (hasMore) {
        _page++;
      }

      error = null;
    } catch (e, stackTrace) {

      error = e.toString();
    }


      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }

  Future<void> refreshSuppliers() async {
    await fetchSuppliers(refresh: true);

  }
}