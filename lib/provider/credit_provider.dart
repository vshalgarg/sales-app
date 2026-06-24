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
    String? fromDate,
    String? toDate,
    int? supplierId,
    int? customerId,
    int page = 0,
    int size = 7,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await searchCredits(
        fromDate: fromDate,
        toDate: toDate,
        supplierId: supplierId,
        customerId: customerId,
        page: page,
        size: size,
      );

      credits = response.content;

      // ASCENDING ORDER BY ID
      credits.sort((a, b) {
        final aNum = int.tryParse(
          (a.billNumber ?? "0").split('-').last,
        ) ??
            0;

        final bNum = int.tryParse(
          (b.billNumber ?? "0").split('-').last,
        ) ??
            0;

        return bNum.compareTo(aNum);
      });

      this.page = response.page;
      totalPages = response.totalPages;
      last = response.last;

      for (final item in credits) {
        debugPrint(
          "ID=${item.id} DATE=${item.date}",
        );
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
    notifyListeners();
  }
}
