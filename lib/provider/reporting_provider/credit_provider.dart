import '../../../../model_classes/common/paginated_response.dart';
import '../../../../pagination/pagination_provider.dart';
import '../../model_classes/credits/add_credit_request.dart';
import '../../model_classes/credits/credit.dart';
import '../../services/credit/credit_services.dart';

class CreditProvider extends PaginationProvider<Credit> {
  final CreditService _service;

  CreditProvider(this._service);

  bool _actionLoading = false;

  bool get actionLoading => _actionLoading;

  String _searchKeyword = "";

  String? _fromDate;
  String? _toDate;
  int? _supplierId;
  int? _customerId;

  void setFromDate(String? value) {
    _fromDate = value;
  }

  void setToDate(String? value) {
    _toDate = value;
  }

  void setSupplierId(int? value) {
    _supplierId = value;
  }

  void setCustomerId(int? value) {
    _customerId = value;
  }

  @override
  Future<PaginatedResponse<Credit>> requestPage({
    required int page,
    required int size,
  }) async {
    final result = _searchKeyword.isEmpty
        ? await _service.getCredits(
      page: page,
      size: size,
      fromDate: _fromDate,
      toDate: _toDate,
      supplierId: _supplierId,
      customerId: _customerId,
    )
        : await _service.searchCredits(
      keyword: _searchKeyword,
      page: page,
      size: size,
      fromDate: _fromDate,
      toDate: _toDate,
      supplierId: _supplierId,
      customerId: _customerId,
    );

    if (result.isFailure || result.data == null) {
      throw Exception(
        result.errorMessage ?? "Failed to load credits",
      );
    }

    return result.data!;
  }
  Future<void> refreshCredits() async {
    await refresh();
  }
  Future<bool> updateCredit({
    required int id,
    required AddCreditRequest request,
  }) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.updateCredit(
        id: id,
        request: request,
      );

      if (result.isSuccess) {
        await refreshCredits();
        return true;
      }

      return false;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }
  Future<bool> deleteCredit(int id) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.deleteCredit(id);

      if (result.isSuccess) {
        await refreshCredits();
        return true;
      }

      return false;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }
  Future<void> search(String keyword) async {
    _searchKeyword = keyword.trim();
    await refreshCredits();
  }

  Future<void> clearSearch() async {
    _searchKeyword = "";
    await refreshCredits();
  }
  Future<bool> addCredit({
    required AddCreditRequest request,
  }) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.addCredit(
        request: request,
      );

      if (result.isSuccess) {
        await refreshCredits();
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
// import '../model_classes/credits/search_credit.dart';
// import '../services/delete_credit_api.dart' as creditApi;
// import '../services/search_credit_api.dart';
//
// class CreditProvider extends ChangeNotifier {
//   bool isLoading = false;
//
//   List<SearchCreditEntry> credits = [];
//
//   int page = 0;
//   int totalPages = 0;
//   bool last = false;
//
//   Future<void> fetchCredits({
//     int page = 0,
//     int size = 20,
//     bool isLoadMore = false,
//     String? fromDate,
//     String? toDate,
//     int? supplierId,
//     int? customerId,
//   }) async {
//     try {
//       if (!isLoadMore) {
//         isLoading = true;
//         notifyListeners();
//       }
//
//       final response = await searchCredits(
//         fromDate: fromDate,
//         toDate: toDate,
//         supplierId: supplierId,
//         customerId: customerId,
//         page: page,
//         size: size,
//       );
//
//       if (isLoadMore) {
//         credits.addAll(response.content);
//       } else {
//         credits = response.content;
//       }
//
//       credits.sort((a, b) {
//         final aNum =
//             int.tryParse((a.billNumber ?? "0").split('-').last) ?? 0;
//         final bNum =
//             int.tryParse((b.billNumber ?? "0").split('-').last) ?? 0;
//
//         return bNum.compareTo(aNum);
//       });
//
//       this.page = response.page;
//       totalPages = response.totalPages;
//       last = response.last;
//
//       for (final item in credits) {
//       }
//     } catch (e) {
//       debugPrint("Credit Error: $e");
//     } finally {
//       isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<bool> deleteCredit(int id) async {
//     try {
//       await creditApi.deleteCredit(id);
//
//       credits.removeWhere((e) => e.id == id);
//
//       notifyListeners();
//
//       return true;
//     } catch (e) {
//       debugPrint("Delete Credit Error => $e");
//       return false;
//     }
//   }
//   void clearCredits() {
//     credits.clear();
//     page = 0;
//     totalPages = 0;
//     last = false;
//     notifyListeners();
//   }
// }
