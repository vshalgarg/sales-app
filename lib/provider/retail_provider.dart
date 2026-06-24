import 'package:flutter/material.dart';
import '../model_classes/retail_model.dart';
import '../services/serach_retail_api.dart';

class RetailProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  List<RetailModel> retailEntries = [];

  int page = 0;
  int totalPages = 0;
  bool last = false;

  Future<void> fetchRetails({
    String? fromDate,
    String? toDate,
    int? customerId,
    int? staffId,
    int? supplierId,
    bool reset = true,
  }) async {
    try {
      if (reset) {
        page = 0;
        retailEntries.clear();
      }

      isLoading = true;
      error = null;
      notifyListeners();

      final result = await RetailApi().searchRetail(
        fromDate: fromDate,
        toDate: toDate,
        customerId: customerId,
        staffId: staffId,
        supplierId: supplierId,
        page: page,
      );

      retailEntries.addAll(
        result["retails"] as List<RetailModel>,
      );

      totalPages = result["totalPages"];
      last = result["last"];

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();

      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore({
    String? fromDate,
    String? toDate,
    int? customerId,
    int? staffId,
    int? supplierId,
  }) async {
    if (last || isLoading) return;

    page++;

    await fetchRetails(
      fromDate: fromDate,
      toDate: toDate,
      customerId: customerId,
      staffId: staffId,
      supplierId: supplierId,
      reset: false,
    );
  }
}