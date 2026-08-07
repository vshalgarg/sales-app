import '../../../../model_classes/common/paginated_response.dart';
import '../../../../pagination/pagination_provider.dart';
import '../../model_classes/customer/add_customer_request.dart';
import '../../model_classes/customer/customer.dart';
import '../../model_classes/customer/customer_details.dart';
import '../../services/customer/customer_services.dart';

class CustomerProvider extends PaginationProvider<Customer> {
  final CustomerService _service;

  CustomerProvider(this._service);

  CustomerDetails? _customerDetails;

  bool _detailsLoading = false;
  bool _actionLoading = false;

  String _searchKeyword = "";

  CustomerDetails? get customerDetails => _customerDetails;

  bool get detailsLoading => _detailsLoading;

  bool get actionLoading => _actionLoading;

  @override
  Future<PaginatedResponse<Customer>> requestPage({
    required int page,
    required int size,
  }) async {
    print("Search keyword = '$_searchKeyword'");

    final result = _searchKeyword.isEmpty
        ? await _service.getCustomers(
      page: page,
      size: size,
    )
        : await _service.searchCustomers(
      keyword: _searchKeyword,
      page: page,
      size: size,
    );

    if (result.isFailure || result.data == null) {
      throw Exception(result.errorMessage ?? "Failed to load customers");
    }

    return result.data!;
  }

  Future<void> search(String keyword) async {
    _searchKeyword = keyword.trim();
    await refreshCustomers();
  }

  Future<void> clearSearch() async {
    _searchKeyword = "";
    await refreshCustomers();
  }

  Future<bool> fetchCustomerDetails(int id) async {
    _detailsLoading = true;
    notifyListeners();

    final result = await _service.getCustomerById(id);

    _detailsLoading = false;

    if (result.isSuccess && result.data != null) {
      _customerDetails = result.data!.data;
    }

    notifyListeners();
    return result.isSuccess && result.data != null;
  }

  Future<bool> addCustomer(AddCustomerRequest request) async {
    _actionLoading = true;
    notifyListeners();

    try {
      print("========== ADD CUSTOMER ==========");
      print("Customer Request: ${request.toJson()}");

      final result = await _service.addCustomer(request);
      print("Status: ${result.statusCode}");
      print("Success: ${result.isSuccess}");
      print("Failure: ${result.isFailure}");
      print("Error: ${result.errorMessage}");
      print("Data: ${result.data}");
      if (result.isSuccess) {
        await refreshCustomers();
        return true;
      }

      return false;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCustomer({
    required int id,
    required AddCustomerRequest request,
  }) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.updateCustomer(
        id: id,
        request: request,
      );

      if (result.isSuccess) {
        // If you want the list to refresh immediately after an update,
        // uncomment the next line.
        await refreshCustomers();

        // If the details screen is open for the same customer,
        // uncomment the next block.
        /*
        if (_customerDetails?.id == id) {
          await fetchCustomerDetails(id);
        }
        */

        return true;
      }

      return false;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteCustomer(String code) async {
    _actionLoading = true;
    notifyListeners();

    try {
      print("Deleting customer: $code");
      final result = await _service.deleteCustomer(code);
      print("Delete success: ${result.isSuccess}");
      print("Delete error: ${result.errorMessage}");
      if (result.isSuccess) {
        await refresh();
      }

      return result.isSuccess;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCustomers() async {
    await refresh();
  }
  void setDetailsLoading(bool value) {
    _detailsLoading = value;
    notifyListeners();
  }
  void clearDetails() {
    _customerDetails = null;
    notifyListeners();
  }
}