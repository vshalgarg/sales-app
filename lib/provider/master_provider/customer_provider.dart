import 'dart:developer';

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

  String _searchKeyword = "";

  CustomerDetails? get customerDetails => _customerDetails;

  bool get detailsLoading => _detailsLoading;

  @override
  Future<PaginatedResponse<Customer>> requestPage({
    required int page,
    required int size,
  }) async {
    log("Search keyword = '$_searchKeyword'");

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
      throw Exception(
        result.errorMessage ?? "Failed to load customers",
      );
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

    try {
      final result = await _service.getCustomerById(id);

      if (result.isSuccess && result.data != null) {
        _customerDetails = result.data!.data;
      }

      return result.isSuccess && result.data != null;
    } finally {
      _detailsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addCustomer(AddCustomerRequest request) async {
    try {
      log("========== ADD CUSTOMER ==========");
      log("Customer Request: ${request.toJson()}");

      final result = await _service.addCustomer(request);

      log("Status: ${result.statusCode}");
      log("Success: ${result.isSuccess}");
      log("Failure: ${result.isFailure}");
      log("Error: ${result.errorMessage}");
      log("Data: ${result.data}");

      if (result.isSuccess) {
        await refreshCustomers();
        return true;
      }

      return false;
    } catch (e) {
      log("Add customer error: $e");
      return false;
    }
  }

  Future<bool> updateCustomer({
    required int id,
    required AddCustomerRequest request,
  }) async {
    try {
      final result = await _service.updateCustomer(
        id: id,
        request: request,
      );

      log("Update customer success: ${result.isSuccess}");
      log("Update customer error: ${result.errorMessage}");

      if (result.isSuccess) {
        try {
          await refreshCustomers();
        } catch (e) {
          log("Refresh customers after update failed: $e");
        }

        return true;
      }

      return false;
    } catch (e) {
      log("Update customer error: $e");
      return false;
    }
  }

  Future<bool> deleteCustomer(String code) async {
    try {
      log("Deleting customer: $code");

      final result = await _service.deleteCustomer(code);

      log("Delete success: ${result.isSuccess}");
      log("Delete error: ${result.errorMessage}");

      if (result.isSuccess) {
        await refresh();
      }

      return result.isSuccess;
    } catch (e) {
      log("Delete customer error: $e");
      return false;
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