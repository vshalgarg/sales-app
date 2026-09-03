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

      log("ERROR: ${result.errorMessage}");


      if (!result.isSuccess) {
        throw Exception(
          result.errorMessage ?? "Failed to add credit entry",
        );
      }

      return true;
    } catch (e, stackTrace) {
      log("ADD CREDIT EXCEPTION: $e",
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
