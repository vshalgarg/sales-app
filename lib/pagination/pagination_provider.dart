import 'package:flutter/material.dart';

import '../model_classes/common/paginated_list.dart';
import '../model_classes/common/paginated_response.dart';
import '../model_classes/common/pagination_state.dart';

abstract class PaginationProvider<T> extends ChangeNotifier {
  final PaginatedList<T> data = PaginatedList<T>();

  bool get loading => data.isLoading;

  String? get error => data.error;

  PaginationState get pagination => data.pagination;

  bool get hasNextPage => pagination.hasMore;
  Future<PaginatedResponse<T>> requestPage({
    required int page,
    required int size,
  });

  Future<void> fetchInitial() async {
    await refresh();
  }

  Future<void> fetchPage(int page) async {
    if (data.isLoading) return;

    data.isLoading = true;
    data.error = null;
    notifyListeners();

    try {
      final response = await requestPage(
        page: page,
        size: data.pagination.pageSize,
      );

      data.update(response);

      data.pagination.currentPage = page;
    } catch (e) {
      data.error = e.toString();
    } finally {
      data.isLoading = false;
      notifyListeners();
    }
  }
  Future<void> fetchNextPage() async {
    if (loading || !hasNextPage) return;

    await fetchPage(
      pagination.currentPage + 1,
    );
  }

  Future<void> refresh() async {
    await fetchPage(data.pagination.currentPage);
  }
  void clear() {
    data.clear();
    notifyListeners();
  }
}