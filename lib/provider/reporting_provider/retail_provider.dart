import '../../../../model_classes/common/paginated_response.dart';
import '../../../../pagination/pagination_provider.dart';
import '../../model_classes/retailers/add_deposit_model.dart';
import '../../model_classes/retailers/add_retail_request.dart';
import '../../model_classes/retailers/retail_deposit_history_model.dart';
import '../../model_classes/retailers/retail_details.dart';
import '../../model_classes/retailers/retail_model.dart';
import '../../services/retail_service.dart';

class RetailProvider extends PaginationProvider<Retail> {
  final RetailService _service;

  RetailProvider(this._service);

  RetailDetails? _retailDetails;

  bool _detailsLoading = false;
  bool _actionLoading = false;
  bool _depositLoading = false;

  List<RetailDepositHistoryModel> _depositHistory = [];

  RetailDetails? get retailDetails => _retailDetails;

  bool get detailsLoading => _detailsLoading;

  bool get actionLoading => _actionLoading;

  bool get depositLoading => _depositLoading;

  List<RetailDepositHistoryModel> get depositHistory =>
      _depositHistory;

  String? _fromDate;
  String? _toDate;
  int? _customerId;
  int? _staffId;
  int? _supplierId;

  void applyFilters({
    String? fromDate,
    String? toDate,
    int? customerId,
    int? staffId,
    int? supplierId,
  }) {
    _fromDate = fromDate;
    _toDate = toDate;
    _customerId = customerId;
    _staffId = staffId;
    _supplierId = supplierId;
  }

  void clearFilters() {
    _fromDate = null;
    _toDate = null;
    _customerId = null;
    _staffId = null;
    _supplierId = null;
  }

  @override
  Future<PaginatedResponse<Retail>> requestPage({
    required int page,
    required int size,
  }) async {
    final result = await _service.searchRetails(
      page: page,
      size: size,
      fromDate: _fromDate,
      toDate: _toDate,
      customerId: _customerId,
      staffId: _staffId,
      supplierId: _supplierId,
    );

    if (result.isFailure || result.data == null) {
      throw Exception(result.errorMessage ?? "Failed to load retails");
    }

    return result.data!;
  }

  Future<void> refreshRetails() async {
    await refresh();
  }
  Future<bool> fetchRetailDetails(int retailId) async {
    _detailsLoading = true;
    notifyListeners();

    final result = await _service.getRetailDetails(retailId);

    _detailsLoading = false;

    if (result.isSuccess && result.data != null) {
      _retailDetails = result.data!;
    }

    notifyListeners();
    return result.isSuccess && result.data != null;
  }

  Future<bool> deleteRetail(int retailId) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.deleteRetail(retailId);

      if (result.isSuccess) {
        await refresh();
      }

      return result.isSuccess;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRetail({
    required int retailId,
    required Map<String, dynamic> body,
  }) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.updateRetail(
        retailId: retailId,
        body: body,
      );

      if (result.isSuccess) {
        await refresh();

        if (_retailDetails?.id == retailId) {
          await fetchRetailDetails(retailId);
        }

        return true;
      }

      return false;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> addDeposit(
      AddDepositModel request) async {
    _depositLoading = true;
    notifyListeners();

    try {
      final result = await _service.addDeposit(request);

      if (result.isSuccess) {
        return {
          "success": true,
          "message": result.data?.message ?? "Success",
        };
      }

      return {
        "success": false,
        "message": result.errorMessage ?? "Something went wrong",
      };
    } finally {
      _depositLoading = false;
      notifyListeners();
    }
  }

  Future<bool> fetchDepositHistory(int retailId) async {
    _depositLoading = true;
    notifyListeners();

    try {
      final result = await _service.getDepositHistory(retailId);

      if (result.isSuccess && result.data != null) {
        _depositHistory = result.data!;
        return true;
      }

      return false;
    } finally {
      _depositLoading = false;
      notifyListeners();
    }
  }

  void clearDetails() {
    _retailDetails = null;
    _depositHistory.clear();
    notifyListeners();
  }
  // CREATE RETAIL

  Future<bool> createRetail(
      Map<String, dynamic> body,
      ) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.createRetail(body);

      if (result.isSuccess) {
        await refresh();
        return true;
      }

      return false;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }

// ADD RETAIL SUPPLIER

  Future<bool> addRetailSupplier(
      Map<String, dynamic> body,
      ) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.addRetailSupplier(body);

      if (result.isSuccess) {
        if (_retailDetails != null) {
          await fetchRetailDetails(_retailDetails!.id);
        }
        return true;
      }

      return false;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }

// UPDATE RETAIL SUPPLIER

  Future<bool> updateRetailSupplier({
    required int retailSupplierId,
    required Map<String, dynamic> body,
  }) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.updateRetailSupplier(
        retailSupplierId: retailSupplierId,
        body: body,
      );

      if (result.isSuccess) {
        if (_retailDetails != null) {
          await fetchRetailDetails(_retailDetails!.id);
        }
        return true;
      }

      return false;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }

// DELETE RETAIL SUPPLIER

  Future<bool> deleteRetailSupplier(
      int retailSupplierId,
      ) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result =
      await _service.deleteRetailSupplier(retailSupplierId);

      if (result.isSuccess) {
        if (_retailDetails != null) {
          await fetchRetailDetails(_retailDetails!.id);
        }
        return true;
      }

      return false;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }
}








// import 'package:flutter/material.dart';
//
// import '../model_classes/retailers/add_deposit_model.dart';
// import '../model_classes/retailers/retail_deposit_history_model.dart';
// import '../model_classes/retailers/retail_model.dart';
// import '../services/add_deposit_api.dart';
// import '../services/delete_retail_api.dart';
// import '../services/get_retail_api.dart';
// import '../services/get_retail_deposit_history.dart';
// import '../services/search_retail_api.dart';
// import '../services/update_retail_api.dart';
//
// class RetailProvider extends ChangeNotifier {
//   bool isLoading = false;
//   String? error;
//
//   final DeleteRetailApi _deleteRetailApi = DeleteRetailApi();
//
//   List<Retail> retailEntries = [];
//
//   int page = 0;
//   int totalPages = 0;
//   bool last = false;
//
//   Future<bool> deleteRetail(int retailId) async {
//     if (isLoading) return false;
//
//     isLoading = true;
//     notifyListeners();
//
//     try {
//       final success = await _deleteRetailApi.deleteRetail(retailId);
//
//       if (success) {
//         retailEntries.removeWhere((e) => e.id == retailId);
//         notifyListeners();
//       }
//
//       return success;
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> fetchRetails({
//     int page = 0,
//     int size = 20,
//     bool isLoadMore = false,
//     String? fromDate,
//     String? toDate,
//     int? customerId,
//     int? staffId,
//     int? supplierId,
//   }) async {
//     try {
//       if (!isLoadMore) {
//         isLoading = true;
//         error = null;
//         notifyListeners();
//       }
//
//       final result = await RetailApi().searchRetail(
//         fromDate: fromDate,
//         toDate: toDate,
//         customerId: customerId,
//         staffId: staffId,
//         supplierId: supplierId,
//         page: page,
//         size: size,
//       );
//
//       final List<Retail> data =
//       result["retails"] as List<Retail>;
//
//       if (isLoadMore) {
//         retailEntries.addAll(data);
//       } else {
//         retailEntries = data;
//       }
//
//       this.page = result["page"];
//       totalPages = result["totalPages"];
//       last = result["last"];
//     } catch (e) {
//       error = e.toString();
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   void clearRetails() {
//     retailEntries.clear();
//     page = 0;
//     totalPages = 0;
//     last = false;
//     notifyListeners();
//   }
// }
//
// class RetailDetailsProvider extends ChangeNotifier {
//   bool isLoading = false;
//   bool isUpdating = false;
//   bool isSavingDeposits = false;
//
//   Retail? retailDetails;
//
//   List<RetailDepositHistoryModel> depositHistory = [];
//
//   String? error;
//
//   Future<void> fetchRetailDetails(int retailId) async {
//     if (isLoading) return;
//
//     isLoading = true;
//     error = null;
//     notifyListeners();
//
//     try {
//       retailDetails = await getRetailDetails(retailId);
//     } catch (e) {
//       error = e.toString();
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> fetchDepositHistory(int retailId) async {
//     try {
//       depositHistory = await getRetailDepositHistory(retailId);
//       notifyListeners();
//     } catch (_) {}
//   }
//
//   Future<Map<String, dynamic>> addDeposits(AddDepositModel model) async {
//     if (isSavingDeposits) {
//       return {
//         "success": false,
//         "message": "Request already in progress",
//       };
//     }
//
//     isSavingDeposits = true;
//     notifyListeners();
//
//     try {
//       return await AddDepositApi().addDeposits(model);
//     } finally {
//       isSavingDeposits = false;
//       notifyListeners();
//     }
//   }
//   Future<bool> updateRetail({
//     required int retailId,
//     required String name,
//     required String date,
//     required int referredByCustomerId,
//     int? staffId,
//   }) async {
//     if (isUpdating) return false;
//
//     isUpdating = true;
//     notifyListeners();
//
//     try {
//       return await UpdateRetailApi().updateRetail(
//         retailId: retailId,
//         name: name,
//         date: date,
//         referredByCustomerId: referredByCustomerId,
//         staffId: staffId,
//       );
//     } finally {
//       isUpdating = false;
//       notifyListeners();
//     }
//   }
// }