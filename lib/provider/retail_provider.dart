import 'package:flutter/material.dart';

import '../model_classes/add_deposit_model.dart';
import '../model_classes/retail_deposit_history_model.dart';
import '../model_classes/retail_model.dart';
import '../services/add_deposit_api.dart';
import '../services/delete_retail_api.dart';
import '../services/get_retail_api.dart';
import '../services/get_retail_deposit_history.dart';
import '../services/search_retail_api.dart';
import '../services/update_retail_api.dart';

class RetailProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  final DeleteRetailApi _deleteRetailApi = DeleteRetailApi();

  List<RetailModel> retailEntries = [];

  int page = 0;
  int totalPages = 0;
  bool last = false;

  Future<bool> deleteRetail(int retailId) async {
    if (isLoading) return false;

    isLoading = true;
    notifyListeners();

    try {
      final success = await _deleteRetailApi.deleteRetail(retailId);

      if (success) {
        retailEntries.removeWhere((e) => e.retailId == retailId);
        notifyListeners();
      }

      return success;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRetails({
    int page = 0,
    int size = 20,
    bool isLoadMore = false,
    String? fromDate,
    String? toDate,
    int? customerId,
    int? staffId,
    int? supplierId,
  }) async {
    try {
      if (!isLoadMore) {
        isLoading = true;
        error = null;
        notifyListeners();
      }

      final result = await RetailApi().searchRetail(
        fromDate: fromDate,
        toDate: toDate,
        customerId: customerId,
        staffId: staffId,
        supplierId: supplierId,
        page: page,
        size: size,
      );

      final List<RetailModel> data =
      result["retails"] as List<RetailModel>;

      if (isLoadMore) {
        retailEntries.addAll(data);
      } else {
        retailEntries = data;
      }

      this.page = result["page"];
      totalPages = result["totalPages"];
      last = result["last"];
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearRetails() {
    retailEntries.clear();
    page = 0;
    totalPages = 0;
    last = false;
    notifyListeners();
  }
}

class RetailDetailsProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isUpdating = false;
  bool isSavingDeposits = false;

  RetailModel? retailDetails;

  List<RetailDepositHistoryModel> depositHistory = [];

  String? error;

  Future<void> fetchRetailDetails(int retailId) async {
    if (isLoading) return;

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      retailDetails = await getRetailDetails(retailId);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDepositHistory(int retailId) async {
    try {
      depositHistory = await getRetailDepositHistory(retailId);
      notifyListeners();
    } catch (_) {}
  }

  Future<Map<String, dynamic>> addDeposits(AddDepositModel model) async {
    if (isSavingDeposits) {
      return {
        "success": false,
        "message": "Request already in progress",
      };
    }

    isSavingDeposits = true;
    notifyListeners();

    try {
      return await AddDepositApi().addDeposits(model);
    } finally {
      isSavingDeposits = false;
      notifyListeners();
    }
  }
  Future<bool> updateRetail({
    required int retailId,
    required String name,
    required String date,
    required int referredByCustomerId,
    int? staffId,
  }) async {
    if (isUpdating) return false;

    isUpdating = true;
    notifyListeners();

    try {
      return await UpdateRetailApi().updateRetail(
        retailId: retailId,
        name: name,
        date: date,
        referredByCustomerId: referredByCustomerId,
        staffId: staffId,
      );
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }
}