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
    isLoading = true;
    notifyListeners();

    final success = await _deleteRetailApi.deleteRetail(retailId);

    if (success) {
      await fetchRetails();
    }

    isLoading = false;
    notifyListeners();

    return success;
  }
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
class RetailDetailsProvider extends ChangeNotifier {
  bool isLoading = false;
bool isUpdating=false;
  bool isSavingDeposits = false;
  RetailModel? retailDetails;
  List<RetailDepositHistoryModel>
  depositHistory = [];
  String? error;

  Future<void> fetchDepositHistory(
      int retailId) async {

    depositHistory =
    await getRetailDepositHistory(
        retailId);

    notifyListeners();
  }
  Future<bool> addDeposits(
      AddDepositModel model,
      ) async {
    try {
      isSavingDeposits = true;

      notifyListeners();

      final success =
      await AddDepositApi()
          .addDeposits(model);

      isSavingDeposits = false;

      notifyListeners();

      return success;
    } catch (e) {
      isSavingDeposits = false;

      notifyListeners();

      rethrow;
    }
  }
  Future<void> fetchRetailDetails(int retailId) async {
    try {
      isLoading = true;
      error = null;

      notifyListeners();

      retailDetails = await getRetailDetails(
        retailId,
      );

      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();

      isLoading = false;
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
    try {
      isUpdating = true;
      notifyListeners();

      final success = await UpdateRetailApi().updateRetail(
        retailId: retailId,
        name: name,
        date: date,
        referredByCustomerId: referredByCustomerId,
        staffId: staffId,
      );

      return success;
    } finally {
      isUpdating = false;
      notifyListeners();
    }
  }
}