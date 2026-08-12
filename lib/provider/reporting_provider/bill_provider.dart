import 'dart:io';

import '../../../../model_classes/common/paginated_response.dart';
import '../../../../pagination/pagination_provider.dart';
import '../../model_classes/bills/add_bill_request.dart';
import '../../model_classes/bills/bill.dart';
import '../../model_classes/bills/bill_details.dart';
import '../../services/bills/bill_service.dart';

class BillProvider extends PaginationProvider<Bill> {
  final BillService _service;

  BillProvider(this._service);

  BillDetails? _billDetails;
  bool hasLoadedBills = false;
  bool _detailsLoading = false;
  bool _actionLoading = false;

  BillDetails? get billDetails => _billDetails;

  bool get detailsLoading => _detailsLoading;

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
  Future<PaginatedResponse<Bill>> requestPage({
    required int page,
    required int size,
  }) async {
    final result = _searchKeyword.isEmpty
        ? await _service.getBills(
      page: page,
      size: size,
      fromDate: _fromDate,
      toDate: _toDate,
      supplierId: _supplierId,
      customerId: _customerId,
    )
        : await _service.searchBills(
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
        result.errorMessage ?? "Failed to load bills",
      );
    }

    return result.data!;
  }

  Future<void> fetchInitialBills() async {
    hasLoadedBills = false;
    notifyListeners();

    await fetchInitial();

    hasLoadedBills = true;
    notifyListeners();
  }

  Future<void> search(String keyword) async {
    _searchKeyword = keyword.trim();
    await refreshBills();
  }

  Future<void> clearSearch() async {
    _searchKeyword = "";
    await refreshBills();
  }
  Future<bool> fetchBillDetails(String billNumber) async {
    _detailsLoading = true;
    notifyListeners();

    final result = await _service.getBillById(billNumber);

    _detailsLoading = false;

    if (result.isSuccess && result.data != null) {
      _billDetails = result.data!;
    }

    notifyListeners();

    return result.isSuccess && result.data != null;
  }

  Future<bool> addBill({
    required AddBillRequest request,
    List<File> images = const [],
  }) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.addBill(
        request: request,
        images: images,
      );

      if (result.isSuccess) {
        await refreshBills();
        return true;
      }

      return false;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }
  Future<bool> updateBill({
    required int id,
    required AddBillRequest request,
    List<String> existingImageKeys = const [],
    List<File> images = const [],
  }) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.updateBill(
        id: id,
        request: request,
        existingImageKeys: existingImageKeys,
        images: images,
      );

      if (result.isSuccess) {
        // Refresh the list if needed
        // await refreshBills();

        // Refresh details if currently viewing the same bill
        // if (_billDetails?.id == id) {
        //   await fetchBillDetails(_billDetails!.billNumber!);
        // }

        return true;
      }

      return false;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBill(String billNumber) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.deleteBill(billNumber);

      if (result.isSuccess) {
        await refreshBills();
      }

      return result.isSuccess;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }
  Future<void> refreshBills() async {
    await refresh();
  }

  void clearDetails() {
    _billDetails = null;
    notifyListeners();
  }
}