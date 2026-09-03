import 'package:flutter/cupertino.dart';
import 'package:hisabio/model_classes/common/paginated_response.dart';

class PaginationState {
  int currentPage;
  int pageSize;
  int totalPages;
  int totalElements;
  bool hasMore;

  PaginationState({
    this.currentPage = 0,
    this.pageSize = 10,
    this.totalPages = 0,
    this.totalElements = 0,
    this.hasMore = true,
  });
  int get lastValidPage {
    if (totalPages == 0) return 0;

    return totalPages - 1;
  }
  void update<T>(PaginatedResponse<T> response) {
    pageSize = response.size;
    totalPages = response.totalPages;
    totalElements = response.totalElements;
    hasMore = !response.last;

    debugPrint("API page = ${response.page},"
        " UI currentPage = $currentPage");
  }
  void reset() {
    currentPage = 0;
    pageSize = 10;
    totalPages = 0;
    totalElements = 0;
    hasMore = true;
  }
}
