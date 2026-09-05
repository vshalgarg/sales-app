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
  final Map<int, SupplierDetails> _supplierDetailsCache = {};

  bool _detailsLoading = false;
  String _searchKeyword = '';

  SupplierDetails? get supplierDetails => _supplierDetails;

  bool get detailsLoading => _detailsLoading;

  String get searchKeyword => _searchKeyword;

  @override
  Future<PaginatedResponse<Supplier>> requestPage({
    required int page,
    required int size,
  }) async {
    final keyword = _searchKeyword;

    final result = keyword.isEmpty
        ? await _service.getSuppliers(
      page: page,
      size: size,
    )
        : await _service.searchSuppliers(
      keyword: keyword,
      page: page,
      size: size,
    );

    if (result.isFailure || result.data == null) {
      throw Exception(result.errorMessage ?? 'Failed to load suppliers');
    }

    return result.data!;
  }

  /// Updates the search keyword without triggering an API request.
  /// Useful when the screen is first opened and page 0 will be fetched once.
  void resetSearchKeyword() {
    _searchKeyword = '';
  }

  Future<void> search(String keyword) async {
    final trimmedKeyword = keyword.trim();

    if (_searchKeyword == trimmedKeyword) {
      return;
    }

    _searchKeyword = trimmedKeyword;
    await refreshSuppliers();
  }

  Future<void> clearSearch() async {
    if (_searchKeyword.isEmpty) {
      return;
    }

    _searchKeyword = '';
    await refreshSuppliers();
  }

  Future<bool> fetchSupplierDetails(int id, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _supplierDetailsCache[id];

      if (cached != null) {
        _supplierDetails = cached;
        notifyListeners();
        return true;
      }
    }

    _detailsLoading = true;
    notifyListeners();

    try {
      final result = await _service.getSupplierById(id);

      if (result.isSuccess && result.data?.data != null) {
        final details = result.data!.data!;
        _supplierDetailsCache[id] = details;
        _supplierDetails = details;
        return true;
      }

      return false;
    } finally {
      _detailsLoading = false;
      notifyListeners();
    }
  }

  Future<String?> addSupplier(AddSupplierRequest request) async {
    // No notifyListeners() here because addSupplier does not change
    // provider-owned list state. This avoids unnecessary screen rebuilds.
    final result = await _service.addSupplier(request);

    if (result.isSuccess && result.data != null) {
      return result.data!.message;
    }

    return result.errorMessage;
  }

  Future<String?> updateSupplier({
    required int id,
    required AddSupplierRequest request,
  }) async {
    final result = await _service.updateSupplier(
      id: id,
      request: request,
    );

    if (result.isSuccess) {
      // The caller already refreshes the visible supplier page after
      // returning from the edit screen. Avoid doing the same API call twice.
      _supplierDetailsCache.remove(id);
      if (_supplierDetails?.id == id) {
        _supplierDetails = null;
      }

      return 'Supplier updated successfully';
    }

    return result.errorMessage;
  }

  Future<bool> deleteSupplier(String code) async {
    final result = await _service.deleteSupplier(code);

    // Keep the refresh here because the deleted item's id is not available
    // to this method and the current pagination page may need replacement.
    if (result.isSuccess) {
      await refresh();
    }

    return result.isSuccess;
  }

  Future<void> refreshSuppliers() async {
    await refresh();
  }

  void clearDetails({int? id}) {
    if (id != null) {
      _supplierDetailsCache.remove(id);
    } else {
      _supplierDetailsCache.clear();
    }

    _supplierDetails = null;
    notifyListeners();
  }

  void invalidateSupplierDetails(int id) {
    _supplierDetailsCache.remove(id);

    if (_supplierDetails?.id == id) {
      _supplierDetails = null;
    }
  }
}
