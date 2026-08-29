import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../model_classes/common/paginated_response.dart';
import '../../model_classes/entries/entries_supplier.dart';
import '../../model_classes/purchases/add_purchase_request.dart';
import '../../model_classes/purchases/get_purchase_model.dart';
import '../../model_classes/purchases/purchase.dart';
import '../../pagination/pagination_provider.dart';
import '../../services/purchase/purchase_service.dart';

class PurchaseProvider extends PaginationProvider<Purchase> {
  final PurchaseService _service;

  PurchaseProvider(this._service);

  PurchaseDetails? _purchaseDetails;

  bool _detailsLoading = false;

  PurchaseDetails? get purchaseDetails => _purchaseDetails;

  bool get detailsLoading => _detailsLoading;


  //String _searchKeyword = "";

  String? _fromDate;
  String? _toDate;
  int? _supplierId;
  int? _customerId;
  int? _staffId;

  void setFromDate(String? value) => _fromDate = value;

  void setToDate(String? value) => _toDate = value;

  void setSupplierId(int? value) => _supplierId = value;

  void setCustomerId(int? value) => _customerId = value;

  void setStaffId(int? value) => _staffId = value;
  @override
  Future<PaginatedResponse<Purchase>> requestPage({
    required int page,
    required int size,
  }) async {
    log(" PURCHASE ");
    log("Requested page = $page");
    final result = await _service.searchPurchases(
      page: page,
      size: size,
      fromDate: _fromDate,
      toDate: _toDate,
      supplierId: _supplierId,
      customerId: _customerId,
      staffId: _staffId,
    );

    if (result.isFailure || result.data == null) {
      throw Exception(
        result.errorMessage ?? "Failed to load purchases",
      );
    }
    log("API page = ${result.data!.page}");
    log("Total pages = ${result.data!.totalPages}");
    log("Last = ${result.data!.last}");
    log("Items = ${result.data!.content.length}");
    return result.data!;
  }

  Future<bool> fetchPurchaseDetails(num id) async {
    _detailsLoading = true;
    notifyListeners();

    final result = await _service.getPurchaseDetails(id);

    _detailsLoading = false;

    if (result.isSuccess && result.data != null) {
      _purchaseDetails = result.data!.data as PurchaseDetails?;
    }

    notifyListeners();

    return result.isSuccess && result.data != null;
  }

  Future<bool> addPurchase({
    required AddPurchaseRequest request,
    required List<List<PlatformFile>> uploadedFiles,
    required List<EntriesModel?> selectedSuppliers,
  }) async {
    notifyListeners();

    try {
      final result = await _service.addPurchase(
        request: request,
        uploadedFiles: uploadedFiles,
        selectedSuppliers: selectedSuppliers,
      );

      if (result.isSuccess &&
          result.data != null &&
          result.data!.success) {
        await refreshPurchases();
        return true;
      }

      return false;

    } finally {
      notifyListeners();
    }
  }
  Future<bool> updatePurchase({
    required num id,
    required String date,
    required num customerId,
    required num supplierId,
    required num staffId,
    required String remarks,
    required List<String> existingImageKeys,
    required List<File> supplierImages,
  }) async {
    notifyListeners();

    try {
      final result = await _service.updatePurchase(
        id: id,
        date: date,
        customerId: customerId,
        supplierId: supplierId,
        staffId: staffId,
        remarks: remarks,
        existingImageKeys: existingImageKeys,
        supplierImages: supplierImages,
      );

      return result.isSuccess;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> deletePurchase(num id) async {
    notifyListeners();

    try {
      final result = await _service.deletePurchase(id);

      if (result.isSuccess) {
        await refreshPurchases();
      }

      return result.isSuccess;
    } finally {
      notifyListeners();
    }
  }

  Future<void> refreshPurchases() async {
    await refresh();
  }

  void clearDetails() {
    _purchaseDetails = null;
    notifyListeners();
  }
}

