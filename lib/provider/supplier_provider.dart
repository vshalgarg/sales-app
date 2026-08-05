import '../../../model_classes/common/paginated_response.dart';
import '../../../pagination/pagination_provider.dart';
import '../model_classes/supplier/add_supplier_request.dart';
import '../model_classes/supplier/supplier.dart';
import '../model_classes/supplier/supplier_details.dart';
import '../services/suppliers/supplier_service.dart';

class SupplierProvider extends PaginationProvider<Supplier> {
  final SupplierService _service;

  SupplierProvider(this._service);

  SupplierDetails? _supplierDetails;

  bool _detailsLoading = false;
  bool _actionLoading = false;

  SupplierDetails? get supplierDetails => _supplierDetails;

  bool get detailsLoading => _detailsLoading;

  bool get actionLoading => _actionLoading;

  String _searchKeyword = "";

  @override
  Future<PaginatedResponse<Supplier>> requestPage({
    required int page,
    required int size,
  }) async {
    print("Search keyword = '$_searchKeyword'");
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
      // notifyListeners();
      // return true;
    }

    notifyListeners();
    return result.isSuccess && result.data != null;
  //  return false;
  }

  Future<bool> addSupplier(AddSupplierRequest request) async {
    _actionLoading = true;
    notifyListeners();
try{
  print("Supplier Request: ${request.toJson()}");
    final result = await _service.addSupplier(request);
    if (result.isSuccess) {
      await refreshSuppliers();
      return true;
    }

    return false;
} finally {
  _actionLoading = false;
  notifyListeners();
}
  }
  Future<bool> updateSupplier({
    required int id,
    required AddSupplierRequest request,
  }) async {
    _actionLoading = true;
    notifyListeners();
    try {
      final result = await _service.updateSupplier(
        id: id,
        request: request,
      );

      if (result.isSuccess) {
        // await refresh();
        //
        // if (_supplierDetails?.id == id) {
        //   await fetchSupplierDetails(id);
        // }

        return true;
      }

      return false;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }

   }
  Future<bool> deleteSupplier(String code) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.deleteSupplier(code);

      if (result.isSuccess) {
        await refresh();
      }

      return result.isSuccess;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }
  // Future<bool> deleteSupplier( String code) async {
  //   print("Deleting supplier: $code");
  //   _actionLoading = true;
  //   notifyListeners();
  //
  //   final result = await _service.deleteSupplier(code);
  //   print("Delete success: ${result.isSuccess}");
  //   print("Delete error: ${result.errorMessage}");
  //   _actionLoading = false;
  //
  //   if (result.isSuccess) {
  //     await refreshSuppliers();
  //     notifyListeners();
  //     return true;
  //   }
  //
  //   notifyListeners();
  //   return false;
  // }
  Future<void> refreshSuppliers() async {
    await refresh();
  }
  void clearDetails() {
    _supplierDetails = null;
    notifyListeners();
  }
}