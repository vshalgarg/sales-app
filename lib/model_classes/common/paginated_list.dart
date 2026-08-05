import 'package:hisabio/model_classes/common/paginated_response.dart';

import 'pagination_state.dart';

class PaginatedList<T> {
  final List<T> items = [];

  final PaginationState pagination = PaginationState();

  bool isLoading = false;
  bool isLoadingMore = false;

  String? error;
  void update(PaginatedResponse<T> response) {
    items
      ..clear()
      ..addAll(response.content);

    pagination.update(response);
  }

  void clear() {
    items.clear();
    pagination.reset();
    error = null;
  }
}
