import 'dart:developer';

import '../../model_classes/common/paginated_response.dart';
import '../../model_classes/credits/add_credit_request.dart';
import '../../model_classes/credits/credit.dart';
import '../../pagination/pagination_provider.dart';
import '../../services/credit/credit_services.dart';

class CreditProvider extends PaginationProvider<Credit> {
  final CreditService _service;

  CreditProvider(this._service);

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

  // ONLY used after adding a new credit.
  Future<void> refreshAfterAdd() async {
    await fetchPage(0);
  }
  Future<bool> deleteCredit(int id) async {
    notifyListeners();

    try {
      final result = await _service.deleteCredit(id);

      if (result.isSuccess) {
        await refreshCredits();
        return true;
      }

      return false;
    } finally {
      notifyListeners();
    }
  }
  Future<bool> addCredit({
    required AddCreditRequest request,
  }) async {
    try {
      final result = await _service.addCredit(
        request: request,
      );

      log("========== ADD CREDIT RESULT ==========");
      log("SUCCESS: ${result.isSuccess}");
      log("DATA: ${result.data}");
      log("ERROR: ${result.errorMessage}");
      log("========================================");

      if (!result.isSuccess) {
        throw Exception(
          result.errorMessage ?? "Failed to add credit entry",
        );
      }

      return true;
    } catch (e, stackTrace) {
      log(
        "ADD CREDIT EXCEPTION: $e",
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}










// import 'dart:developer';
// import '../../../../model_classes/common/paginated_response.dart';
// import '../../../../pagination/pagination_provider.dart';
// import '../../model_classes/credits/add_credit_request.dart';
// import '../../model_classes/credits/credit.dart';
// import '../../services/credit/credit_services.dart';
// class CreditProvider extends PaginationProvider<Credit> {
//   final CreditService _service;
//
//   CreditProvider(this._service);
//
//   String _searchKeyword = "";
//
//   String? _fromDate;
//   String? _toDate;
//   int? _supplierId;
//   int? _customerId;
//
//   void setFromDate(String? value) {
//     _fromDate = value;
//   }
//
//   void setToDate(String? value) {
//     _toDate = value;
//   }
//
//   void setSupplierId(int? value) {
//     _supplierId = value;
//   }
//
//   void setCustomerId(int? value) {
//     _customerId = value;
//   }
//
//   @override
//   Future<PaginatedResponse<Credit>> requestPage({
//     required int page,
//     required int size,
//   }) async {
//     final result = _searchKeyword.isEmpty
//         ? await _service.getCredits(
//       page: page,
//       size: size,
//       fromDate: _fromDate,
//       toDate: _toDate,
//       supplierId: _supplierId,
//       customerId: _customerId,
//     )
//         : await _service.searchCredits(
//       keyword: _searchKeyword,
//       page: page,
//       size: size,
//       fromDate: _fromDate,
//       toDate: _toDate,
//       supplierId: _supplierId,
//       customerId: _customerId,
//     );
//
//     if (result.isFailure || result.data == null) {
//       throw Exception(result.errorMessage ?? "Failed to load credits");
//     }
//
//     return result.data!;
//   }
//
//   Future<void> refreshCredits() async {
//     await refresh();
//   }
//   Future<void> refreshAfterAdd() async {
//     data.pagination.currentPage = 0;
//     await refresh();
//   }
//
//   Future<bool> updateCredit({
//     required int id,
//     required AddCreditRequest request,
//   }) async {
//     notifyListeners();
//
//     try {
//       final result = await _service.updateCredit(id: id, request: request);
//
//       if (result.isSuccess) {
//         await refreshCredits();
//         return true;
//       }
//
//       return false;
//     } finally {
//       notifyListeners();
//     }
//   }
//
//   Future<bool> deleteCredit(int id) async {
//     notifyListeners();
//
//     try {
//       final result = await _service.deleteCredit(id);
//
//       if (result.isSuccess) {
//         await refreshCredits();
//         return true;
//       }
//
//       return false;
//     } finally {
//       notifyListeners();
//     }
//   }
//
//   Future<void> search(String keyword) async {
//     _searchKeyword = keyword.trim();
//     await refreshCredits();
//   }
//
//   Future<void> clearSearch() async {
//     _searchKeyword = "";
//     await refreshCredits();
//   }
//
//   Future<bool> addCredit({
//     required AddCreditRequest request,
//   }) async {
//     try {
//       final result = await _service.addCredit(
//         request: request,
//       );
//
//       log("========== ADD CREDIT RESULT ==========");
//       log("SUCCESS: ${result.isSuccess}");
//       log("DATA: ${result.data}");
//       log("ERROR: ${result.errorMessage}");
//       log("========================================");
//
//       if (!result.isSuccess) {
//         throw Exception(
//           result.errorMessage ?? "Failed to add credit entry",
//         );
//       }
//
//       return true;
//     } catch (e, stackTrace) {
//       log(
//         "ADD CREDIT EXCEPTION: $e",
//         stackTrace: stackTrace,
//       );
//
//       rethrow;
//     }
//   }
// }
