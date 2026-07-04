import 'package:flutter/material.dart';
import '../model_classes/search_purchase.dart';
import '../services/purchase_delete_api.dart';
import '../services/search_purchase_api.dart';

class PurchaseProvider extends ChangeNotifier {
  List<PurchaseEntry> _purchaseEntries = [];

  List<PurchaseEntry> get purchaseEntries => _purchaseEntries;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _error;

  String? get error => _error;

  int _page = 0;

  int get page => _page;

  int _size = 20;

  int get size => _size;

  int totalPages = 0;
  bool last = false;

  Future<void> searchPurchases({
    int page = 0,
    int size = 20,
    bool isLoadMore = false,
    String? fromDate,
    String? toDate,
    int? supplierId,
    int? customerId,
    int? staffId,
  }) async {
    try {
      if (!isLoadMore) {
        _isLoading = true;
        _error = null;
        notifyListeners();
      }

      final response = await searchPurchaseEntries(
        fromDate: fromDate,
        toDate: toDate,
        supplierId: supplierId,
        customerId: customerId,
        staffId: staffId,
        page: page,
        size: size,
      );

      if (isLoadMore) {
        _purchaseEntries.addAll(response.content);
      } else {
        _purchaseEntries = response.content;
      }

      _page = response.page;
      _size = size;
      totalPages = response.totalPages;
      last = response.last;
    } catch (e) {
      _error = e.toString();
      debugPrint("Purchase Search Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePurchaseEntry(int id, String token) async {
    try {
      await deletePurchase(id, token);

      _purchaseEntries.removeWhere((e) => e.id == id);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void clearSearch() {
    _purchaseEntries.clear();
    _error = null;
    _page = 0;
    totalPages = 0;
    last = false;
    notifyListeners();
  }
}
