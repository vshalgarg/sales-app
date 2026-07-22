import 'package:flutter/material.dart';
import '../model_classes/search_purchase.dart';
import '../services/purchase_delete_api.dart' as purchaseApi;
import '../services/search_purchase_api.dart';
import '../shared_preferences/login_token.dart';

class PurchaseProvider extends ChangeNotifier {
  List<PurchaseEntry> _purchaseEntries = [];

  List<PurchaseEntry> get purchaseEntries => _purchaseEntries;

  bool _isLoading = false;
  String? _successMessage;

  String? get successMessage => _successMessage;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;
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
    print("searchPurchases called");
    try {
      if (!isLoadMore) {
        _isLoading = true;
        _error = null;
        notifyListeners();
      }
      print("API CALLED");
      final response = await searchPurchaseEntries(
        fromDate: fromDate,
        toDate: toDate,
        supplierId: supplierId,
        customerId: customerId,
        staffId: staffId,
        page: page,
        size: size,
      );
      for (final item in response.content) {
        if (item.id == 43) {
          print(
            "Purchase 43 => "
                "Customer: ${item.customerName}, "
                "Supplier: ${item.supplierName}, "
                "Staff: ${item.staffName}",
          );
        }
      }
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

  Future<bool> deletePurchase(int id) async {
    try {
      _errorMessage = null;
      _successMessage = null;

      final token = await AppStorage.getToken();

      if (token == null) {
        throw Exception("Token not found");
      }

      final response = await purchaseApi.deletePurchase(
        id,
        token,
      );

      _purchaseEntries.removeWhere((e) => e.id == id);

      _successMessage = response.message;

      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");

      debugPrint("Delete Purchase Error => $e");

      notifyListeners();

      return false;
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
