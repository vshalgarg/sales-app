
import 'package:flutter/material.dart';

import '../model_classes/common/paginated_list.dart';
import '../model_classes/common/paginated_response.dart';
import '../model_classes/common/pagination_state.dart';

abstract class PaginationProvider<T> extends ChangeNotifier {
  final PaginatedList<T> data = PaginatedList<T>();

  bool get loading => data.isLoading;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  String? get error => data.error;

  PaginationState get pagination => data.pagination;

  bool get hasNextPage => pagination.hasMore;

  int _requestId = 0;
  bool _isInitialFetch = false;

  bool get isInitialFetch => _isInitialFetch;

  Future<PaginatedResponse<T>> requestPage({
    required int page,
    required int size,
  });

  Future<void> fetchInitial() async {
    if (data.items.isNotEmpty || data.isLoading) return;

    _isInitialFetch = true;
    data.isLoading = true;
    data.error = null;
    notifyListeners();

    try {
      await fetchPage(0);
    } finally {
      _isInitialFetch = false;
    }
  }

  Future<void> fetchPage(int page) async {
    final requestId = ++_requestId;

    data.error = null;

    try {
      final response = await requestPage(
        page: page,
        size: data.pagination.pageSize,
      );

      if (requestId != _requestId) return;

      data.update(response);
      data.pagination.currentPage = page;
    } catch (e) {
      if (requestId != _requestId) return;
      data.error = e.toString();
    } finally {
      if (requestId == _requestId) {
        data.isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchNextPage() async {
    if (loading || !hasNextPage) return;

    await fetchPage(pagination.currentPage + 1);
  }

  // Refresh without triggering the full-page loader.
  Future<void> refresh() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    final requestId = ++_requestId;

    pagination.currentPage = 0;
    data.error = null;

    notifyListeners();

    try {
      final response = await requestPage(
        page: 0,
        size: data.pagination.pageSize,
      );

      if (requestId != _requestId) return;

      data.update(response);
      data.pagination.currentPage = 0;
    } catch (e) {
      if (requestId != _requestId) return;
      data.error = e.toString();
    } finally {
      if (requestId == _requestId) {
        _isRefreshing = false;
        data.isLoading = false;
        notifyListeners();
      }
    }
  }

  void clear() {
    _requestId++;

    _isRefreshing = false;
    data.clear();
    data.isLoading = false;

    notifyListeners();
  }
}
