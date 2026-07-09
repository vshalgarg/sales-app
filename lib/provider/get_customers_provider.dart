import 'package:flutter/material.dart';
import '../services/get_customers.dart';

class CustomersProvider extends ChangeNotifier {
  final GetCustomersApi _api = GetCustomersApi();

  List<dynamic> customers = [];

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;

  int _page = 0;
  final int _size = 10;

  String? error;

  Future<void> fetchCustomers({bool refresh = false}) async {
    if (isLoading || isLoadingMore) return;

    if (refresh) {
      _page = 0;
      customers.clear();
      hasMore = true;
      error = null;
    }

    if (!hasMore) return;

    if (_page == 0) {
      isLoading = true;
    } else {
      isLoadingMore = true;
    }

    notifyListeners();

    try {
      final response = await _api.getCustomers(
        page: _page,
        size: _size,
      );
      print("GET CUSTOMERS RESPONSE: $response");
      final List<dynamic> newCustomers =
          response["content"] ?? [];

      customers.addAll(newCustomers);

      hasMore = !(response["last"] ?? true);

      if (hasMore) {
        _page++;
      }
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    isLoadingMore = false;

    notifyListeners();
  }

  Future<void> refreshCustomers() async {
    await fetchCustomers(refresh: true);
  }
}