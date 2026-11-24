
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
  bool _showLoader = true;

  @override
  Future<PaginatedResponse<Supplier>> requestPage({
    required int page,
    required int size,
  }) async {
    final result = _searchKeyword.isEmpty
        ? await _service.getSuppliers(
      page: page,
      size: size,
      showLoader: _showLoader,
    )
        : await _service.searchSuppliers(
      keyword: _searchKeyword,
      page: page,
      size: size,
      showLoader: _showLoader,
    );

    if (result.isFailure || result.data == null) {
      throw Exception(
        result.errorMessage ?? "Failed to load suppliers",
      );
    }

    return result.data!;
  }

  Future<void> initializeSuppliers() async {
    _searchKeyword = "";
    _showLoader = true;
    await fetchPage(0);
  }

  Future<void> search(String keyword) async {
    _searchKeyword = keyword.trim();
    await refreshSuppliers();
  }

  Future<void> clearSearch() async {
    _searchKeyword = "";
    await refreshSuppliers();
  }

  Future<void> refreshSuppliers({bool showLoader = true}) async {
    _showLoader = showLoader;

    try {
      await refresh();
    } finally {
      _showLoader = true;
    }
  }

  Future<SupplierDetails?> fetchSupplierDetails(int id) async {
    _detailsLoading = true;
    notifyListeners();

    try {
      final result = await _service.getSupplierById(id);

      if (result.isSuccess && result.data != null) {
        _supplierDetails = result.data!.data;
        return _supplierDetails;
      }

      return null;
    } catch (e) {
      return null;
    } finally {
      _detailsLoading = false;
      notifyListeners();
    }
  }

  Future<String?> addSupplier(AddSupplierRequest request) async {
    try {
      final result = await _service.addSupplier(request);

      if (result.isSuccess && result.data != null) {
        return result.data!.message;
      }

      return result.errorMessage;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateSupplier({
    required int id,
    required AddSupplierRequest request,
  }) async {
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
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> deleteSupplier(String code) async {
    try {
      final result = await _service.deleteSupplier(code);

      if (result.isSuccess) {
        await refresh();
      }

      return result.isSuccess;
    } catch (e) {
      return false;
    }
  }

  void clearDetails() {
    _supplierDetails = null;
    notifyListeners();
  }
}
