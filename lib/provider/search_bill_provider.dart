import 'package:flutter/material.dart';
import '../model_classes/search_bills.dart';
import '../services/search_bill_api.dart' as billService;

class BillsProvider extends ChangeNotifier {
  List<BillEntry> bills = [];

  bool isBillsLoading = false;
  Future<void> fetchBills({
    String? fromDate,
    String? toDate,
    int? supplierId,
    int? customerId,
  }) async {
    isBillsLoading = true;
    notifyListeners();

    try {
      bills = await billService.searchBills(
        fromDate: fromDate,
        toDate: toDate,
        supplierId: supplierId,
        customerId: customerId,
      );

      bills.sort((a, b) {
        final aNum = int.tryParse(
          a.billNumber.split('-').last,
        ) ?? 0;

        final bNum = int.tryParse(
          b.billNumber.split('-').last,
        ) ?? 0;

        return bNum.compareTo(aNum);
      });
    } finally {
      isBillsLoading = false;
      notifyListeners();
    }
  }
}
