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
      throw Exception(result.errorMessage ?? "Failed to load credits");
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
      final result = await _service.updateCredit(id: id, request: request);

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

  Future<bool> addCredit({required AddCreditRequest request}) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.addCredit(request: request);

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
