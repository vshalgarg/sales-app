import 'package:flutter/material.dart';

import '../model_classes/common/paginated_list.dart';
import '../model_classes/common/paginated_response.dart';
import '../model_classes/common/pagination_state.dart';

abstract class PaginationProvider<T> extends ChangeNotifier {
  final PaginatedList<T> data = PaginatedList<T>();

  bool _requestInProgress = false;
  int _requestVersion = 0;

  bool get loading => data.isLoading;
  String? get error => data.error;
  PaginationState get pagination => data.pagination;
  bool get hasNextPage => pagination.hasMore;

  Future<PaginatedResponse<T>> requestPage({
    required int page,
    required int size,
  });

  Future<void> fetchInitial() async {
    await fetchPage(0);
  }

  Future<void> fetchPage(int page) async {
    if (_requestInProgress) return;
    if (page < 0) return;

    final requestVersion = ++_requestVersion;
    _requestInProgress = true;

    data.isLoading = true;
    data.error = null;
    notifyListeners();

    try {
      final response = await requestPage(
        page: page,
        size: data.pagination.pageSize,
      );

      // Ignore a response if a newer request has been started.
      if (requestVersion != _requestVersion) return;

      data.update(response);
      data.pagination.currentPage = page;
    } catch (e) {
      if (requestVersion == _requestVersion) {
        data.error = e.toString();
      }
    } finally {
      if (requestVersion == _requestVersion) {
        data.isLoading = false;
        notifyListeners();
      }
      _requestInProgress = false;
    }
  }

  Future<void> fetchNextPage() async {
    if (loading || !hasNextPage) return;

    await fetchPage(pagination.currentPage + 1);
  }

  Future<void> refresh() async {
    await fetchPage(pagination.currentPage);
  }

  void clear() {
    ++_requestVersion;
    data.clear();
    notifyListeners();
  }
}
