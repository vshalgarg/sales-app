import 'package:flutter/material.dart';
import '../model_classes/search_bills.dart';
import '../services/search_bill_api.dart' as billService;

class BillsProvider extends ChangeNotifier {
  List<BillEntry> bills = [];

  bool isBillsLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;

  Future<bool> fetchBills({
    int page = 0,
    bool isLoadMore = false,
    String? fromDate,
    String? toDate,
    int? supplierId,
    int? customerId,
  }) async {
    if (isLoadMore) {
      if (isLoadingMore || !hasMore) return false;
      isLoadingMore = true;
    } else {
      isBillsLoading = true;
      hasMore = true;
    }

    notifyListeners();

    try {
      final newBills = await billService.searchBills(
        page: page,
        fromDate: fromDate,
        toDate: toDate,
        supplierId: supplierId,
        customerId: customerId,
      );

      if (isLoadMore) {
        bills.addAll(newBills);
      } else {
        bills = newBills;
      }

      bills.sort((a, b) {
        final aNum = int.tryParse(a.billNumber.split('-').last) ?? 0;
        final bNum = int.tryParse(b.billNumber.split('-').last) ?? 0;
        return bNum.compareTo(aNum);
      });

      hasMore = newBills.isNotEmpty;

      return newBills.isNotEmpty;
    } finally {
      if (isLoadMore) {
        isLoadingMore = false;
      } else {
        isBillsLoading = false;
      }

      notifyListeners();
    }
  }
}