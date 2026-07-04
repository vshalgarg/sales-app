import 'package:flutter/material.dart';

import '../model_classes/search_credit.dart';
import '../services/search_credit_api.dart';

class CreditProvider extends ChangeNotifier {
  bool isLoading = false;

  List<SearchCreditEntry> credits = [];

  int page = 0;
  int totalPages = 0;
  bool last = false;

  Future<void> fetchCredits({
    int page = 0,
    int size = 20,
    bool isLoadMore = false,
    String? fromDate,
    String? toDate,
    int? supplierId,
    int? customerId,
  }) async {
    try {
      if (!isLoadMore) {
        isLoading = true;
        notifyListeners();
      }

      final response = await searchCredits(
        fromDate: fromDate,
        toDate: toDate,
        supplierId: supplierId,
        customerId: customerId,
        page: page,
        size: size,
      );

      if (isLoadMore) {
        credits.addAll(response.content);
      } else {
        credits = response.content;
      }

      // Sort descending by bill number
      credits.sort((a, b) {
        final aNum =
            int.tryParse((a.billNumber ?? "0").split('-').last) ?? 0;
        final bNum =
            int.tryParse((b.billNumber ?? "0").split('-').last) ?? 0;

        return bNum.compareTo(aNum);
      });

      this.page = response.page;
      totalPages = response.totalPages;
      last = response.last;

      for (final item in credits) {
        debugPrint("ID=${item.id} DATE=${item.date}");
      }
    } catch (e) {
      debugPrint("Credit Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  void clearCredits() {
    credits.clear();
    page = 0;
    totalPages = 0;
    last = false;
    notifyListeners();
  }
}
