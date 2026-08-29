import '../../../../model_classes/common/paginated_response.dart';
import '../../../../pagination/pagination_provider.dart';
import '../../model_classes/retailers/add_deposit_model.dart';
import '../../model_classes/retailers/retail_deposit_history_model.dart';
import '../../model_classes/retailers/retail_details.dart';
import '../../model_classes/retailers/retail_model.dart';
import '../../services/retail/retail_service.dart';

class RetailProvider extends PaginationProvider<Retail> {
  final RetailService _service;

  RetailProvider(this._service);

  RetailDetails? _retailDetails;

  bool _detailsLoading = false;
  bool _depositLoading = false;

  List<RetailDepositHistoryModel> _depositHistory = [];

  RetailDetails? get retailDetails => _retailDetails;

  bool get detailsLoading => _detailsLoading;
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


    try {
      final result = await _service.deleteRetail(retailId);

      if (result.isSuccess) {
        await refresh();
      }

      return result.isSuccess;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateRetail({
    required int retailId,
    required Map<String, dynamic> body,
  }) async {


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
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> addDeposit(
      AddDepositModel request,
      ) async {
    _depositLoading = true;
    notifyListeners();

    try {
      final result = await _service.addDeposit(request);

      if (result.isSuccess) {
        // Refresh both supplier summary and deposit history immediately.
        if (_retailDetails != null) {
          await fetchRetailDetails(_retailDetails!.id);
          await fetchDepositHistory(_retailDetails!.id);
        }

        return {
          "success": true,
          "message": result.data?.message ?? "Deposit added successfully",
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
    try {
      final result = await _service.getDepositHistory(retailId);

      if (result.isSuccess && result.data != null) {
        _depositHistory = result.data!;
        notifyListeners();
        return true;
      }

      return false;
    } catch (_) {
      return false;
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


    try {
      final result = await _service.createRetail(body);

      if (result.isSuccess) {
        await refresh();
        return true;
      }

      return false;
    } finally {
      notifyListeners();
    }
  }

// ADD RETAIL SUPPLIER

  Future<bool> addRetailSupplier(
      Map<String, dynamic> body,
      ) async {


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
      notifyListeners();
    }
  }

// UPDATE RETAIL SUPPLIER

  Future<bool> updateRetailSupplier({
    required int retailSupplierId,
    required Map<String, dynamic> body,
  }) async {


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
      notifyListeners();
    }
  }

// DELETE RETAIL SUPPLIER

  Future<bool> deleteRetailSupplier(
      int retailSupplierId,
      ) async {


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
      notifyListeners();
    }
  }
}