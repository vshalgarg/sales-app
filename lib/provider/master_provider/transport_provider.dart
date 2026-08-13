import '../../../../model_classes/common/paginated_response.dart';
import '../../../../pagination/pagination_provider.dart';
import '../../model_classes/Transport/add_transport_request.dart';
import '../../model_classes/Transport/transport.dart';
import '../../model_classes/transport/transport_details.dart';
import '../../services/transport/transport_service.dart';

class TransportProvider extends PaginationProvider {
  final TransportService _service;

  TransportProvider(this._service);

  TransportDetails? _transportDetails;

  bool _detailsLoading = false;
  bool _actionLoading = false;

  TransportDetails? get transportDetails => _transportDetails;

  bool get detailsLoading => _detailsLoading;

  bool get actionLoading => _actionLoading;

  String _searchKeyword = "";

  @override
  Future<PaginatedResponse<Transport>> requestPage({
    required int page,
    required int size,
  }) async {
    final result = _searchKeyword.isEmpty
        ? await _service.getTransports(
      page: page,
      size: size,
    )
        : await _service.searchTransports(
      keyword: _searchKeyword,
      page: page,
      size: size,
    );

    if (result.isFailure || result.data == null) {
      throw Exception(
        result.errorMessage ?? "Failed to load transports",
      );
    }

    return result.data!;
  }


  // LOAD ALL TRANSPORTS


  Future<void> fetchAllTransports() async {
    data.isLoading = true;
    data.error = null;
    notifyListeners();

    try {
      const int pageSize = 100;

      int page = 0;
      bool hasMore = true;

      final List<Transport> allTransports = [];

      while (hasMore) {
        final response = await requestPage(
          page: page,
          size: pageSize,
        );

        allTransports.addAll(response.content);

        hasMore = !response.last;

        page++;
      }

      data.items
        ..clear()
        ..addAll(allTransports);
    } catch (e) {
      data.error = e.toString();
    } finally {
      data.isLoading = false;
      notifyListeners();
    }
  }

  Future search(String keyword) async {
    _searchKeyword = keyword.trim();
    await refreshTransports();
  }

  Future clearSearch() async {
    _searchKeyword = "";
    await refreshTransports();
  }

  Future fetchTransportDetails(int id) async {
    _detailsLoading = true;
    notifyListeners();

    final result = await _service.getTransportById(id);

    _detailsLoading = false;

    if (result.isSuccess && result.data != null) {
      _transportDetails = result.data!;
    }

    notifyListeners();

    return result.isSuccess && result.data != null;
  }

  Future addTransport(AddTransportRequest request) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.addTransport(request);

      if (result.isSuccess) {
        await refreshTransports();
        return true;
      }

      return false;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }

  Future updateTransport({
    required int id,
    required AddTransportRequest request,
  }) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.updateTransport(
        id: id,
        request: request,
      );

      if (result.isSuccess) {
        if (_transportDetails?.id == id) {
          await fetchTransportDetails(id);
        }

        return true;
      }

      return false;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }

  Future deleteTransport(int id) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.deleteTransport(id);

      if (result.isSuccess) {
        await fetchInitial();
      }

      return result.isSuccess;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }

  Future refreshTransports() async {
    await refresh();
  }

  void clearDetails() {
    _transportDetails = null;
    notifyListeners();
  }
}