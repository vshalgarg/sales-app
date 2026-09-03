import 'dart:developer';

import '../../../../model_classes/common/paginated_response.dart';
import '../../../../pagination/pagination_provider.dart';
import '../../model_classes/supplier/add_supplier_request.dart';
import '../../model_classes/supplier/supplier.dart';
import '../../model_classes/supplier/supplier_details.dart';
import '../../services/suppliers/supplier_service.dart';

class SupplierProvider extends PaginationProvider<Supplier> {
  final SupplierService _service;

  SupplierProvider(this._service);

  SupplierDetails? _supplierDetails;

  bool _detailsLoading = false;

  SupplierDetails? get supplierDetails => _supplierDetails;

  bool get detailsLoading => _detailsLoading;

  String _searchKeyword = "";

  @override
  Future<PaginatedResponse<Supplier>> requestPage({
    required int page,
    required int size,
  }) async {
    final result = _searchKeyword.isEmpty
        ? await _service.getSuppliers(
      page: page,
      size: size,
    )
        : await _service.searchSuppliers(
      keyword: _searchKeyword,
      page: page,
      size: size,
    );

    if (result.isFailure || result.data == null) {
      throw Exception(result.errorMessage ?? "Failed to load suppliers");
    }

    return result.data!;
  }

  Future<void> search(String keyword) async {
    _searchKeyword = keyword.trim();
    await refreshSuppliers();
  }

  Future<void> clearSearch() async {
    _searchKeyword = "";
    await refreshSuppliers();
  }

  Future<bool> fetchSupplierDetails(int id) async {
    _detailsLoading = true;
    notifyListeners();

    final result = await _service.getSupplierById(id);

    _detailsLoading = false;

    if (result.isSuccess && result.data != null) {
      _supplierDetails = result.data!.data;
    }

    notifyListeners();
    return result.isSuccess && result.data != null;
  }

  Future<String?> addSupplier(AddSupplierRequest request) async {
    notifyListeners();

    try {

      final result = await _service.addSupplier(request);

      if (result.isSuccess && result.data != null) {
        return result.data!.message;
      }

      return result.errorMessage;
    } finally {
      notifyListeners();
    }
  }
  Future<String?> updateSupplier({
    required int id,
    required AddSupplierRequest request,
  }) async {
    notifyListeners();

    try {
      final result = await _service.updateSupplier(
        id: id,
        request: request,
      );

      if (result.isSuccess) {
        await refresh();

        return "Supplier updated successfully";
      }

      return result.errorMessage;
    } finally {
      notifyListeners();
    }
  }
  Future<bool> deleteSupplier(String code) async {

    notifyListeners();

    try {
      final result = await _service.deleteSupplier(code);

      if (result.isSuccess) {
        await refresh();
      }

      return result.isSuccess;
    } finally {
      notifyListeners();
    }
  }
  Future<void> refreshSuppliers() async {
    await refresh();
  }
  void clearDetails() {
    _supplierDetails = null;
    notifyListeners();
  }
}