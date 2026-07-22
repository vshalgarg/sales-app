import 'package:flutter/material.dart';
import '../model_classes/reporting_get_bill.dart';
import '../model_classes/search_bills.dart';
import '../services/bills_detail_api.dart';
import '../services/delete_bills_api.dart' as billApi;
import '../services/search_bill_api.dart' as billService;

class BillsProvider extends ChangeNotifier {
  List<BillEntry> bills = [];
  BillResponse? bill;
  bool isBillsLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  bool isLoading = false;
  String?error;

  Future<bool> deleteBill(String billNumber) async {
    try {
      final success = await billApi.deleteBill(billNumber);

      if (success) {
        bills.removeWhere((bill) => bill.billNumber == billNumber);
        notifyListeners();
      }

      return success;
    } catch (e) {
      debugPrint("Delete Bill Error: $e");
      return false;
    }
  }
  Future<void> fetchBillById(String billNumber) async {
    isLoading = true;
    error = null;
    bill = null;
    notifyListeners();

    try {
      print("Fetching bill: $billNumber");
      final result= await getBillDetails(billNumber);
      bill=result;
      print("API returned: $result");
      print("Provider bill assigned: $bill");
    } catch (e, stack) {
      print("🔥 fetchBillById error: $e");
      print(stack);

      error = e.toString().replaceFirst("Exception: ", "");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
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
      debugPrint("Fetched ${newBills.length} bills");

      for (final bill in newBills) {
        debugPrint(
          "${bill.billNumber} | ${bill.date} | ${bill.supplierName}",
        );
      }

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