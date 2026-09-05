import '../../../../model_classes/common/paginated_response.dart';
import '../../../../pagination/pagination_provider.dart';
import '../../model_classes/Transport/add_transport_request.dart';
import '../../model_classes/Transport/transport.dart';
import '../../model_classes/transport/transport_details.dart';
import '../../services/transport/transport_service.dart';

class TransportProvider extends PaginationProvider<Transport> {
  final TransportService _service;

  TransportProvider(this._service);

  TransportDetails? _transportDetails;
  bool _detailsLoading = false;

  String? _message;
  String _searchKeyword = '';

  bool _allTransportsLoaded = false;
  Future<void>? _allTransportsRequest;

  TransportDetails? get transportDetails => _transportDetails;
  String? get message => _message;
  bool get detailsLoading => _detailsLoading;
  bool get allTransportsLoaded => _allTransportsLoaded;

  void clearMessage() {
    _message = null;
  }

  @override
  Future<PaginatedResponse<Transport>> requestPage({
    required int page,
    required int size,
  }) async {
    final result = _searchKeyword.isEmpty
        ? await _service.getTransports(page: page, size: size)
        : await _service.searchTransports(
      keyword: _searchKeyword,
      page: page,
      size: size,
    );

    if (result.isFailure || result.data == null) {
      throw Exception(
        result.errorMessage ?? 'Failed to load transports',
      );
    }

    return result.data!;
  }

  /// Loads all transports once for dropdowns/forms.
  /// Concurrent callers share the same Future instead of starting
  /// multiple full pagination requests.
  Future<void> ensureAllTransportsLoaded() async {
    if (_allTransportsLoaded && data.items.isNotEmpty) return;

    _allTransportsRequest ??= _loadAllTransports();

    try {
      await _allTransportsRequest;
    } finally {
      _allTransportsRequest = null;
    }
  }

  Future<void> fetchAllTransports() async {
    await ensureAllTransportsLoaded();
  }

  Future<void> _loadAllTransports() async {
    data.isLoading = true;
    data.error = null;
    notifyListeners();

    try {
      const pageSize = 100;
      var page = 0;
      var hasMore = true;
      final allTransports = <Transport>[];

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

      _allTransportsLoaded = true;
    } catch (e) {
      data.error = e.toString();
      _allTransportsLoaded = false;
    } finally {
      data.isLoading = false;
      notifyListeners();
    }
  }

  Future<void> search(String keyword) async {
    final value = keyword.trim();

    if (_searchKeyword == value) return;

    _searchKeyword = value;
    _allTransportsLoaded = false;
    await refresh();
  }

  Future<void> clearSearch() async {
    if (_searchKeyword.isEmpty) return;

    _searchKeyword = '';
    _allTransportsLoaded = false;
    await refresh();
  }

  Future<bool> fetchTransportDetails(int id) async {
    _detailsLoading = true;
    notifyListeners();

    try {
      final result = await _service.getTransportById(id);

      if (result.isSuccess && result.data != null) {
        _transportDetails = result.data!;
        return true;
      }

      return false;
    } finally {
      _detailsLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTransport(AddTransportRequest request) async {
    _message = null;

    try {
      final result = await _service.addTransport(request);

      if (result.isSuccess) {
        _message = result.data?.message;
        _allTransportsLoaded = false;
        await refresh();
        return true;
      }

      _message = result.errorMessage;
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateTransport({
    required int id,
    required AddTransportRequest request,
  }) async {
    _message = null;

    try {
      final result = await _service.updateTransport(
        id: id,
        request: request,
      );

      if (result.isSuccess) {
        _message = result.data?.message;
        _allTransportsLoaded = false;

        if (_transportDetails?.id == id) {
          await fetchTransportDetails(id);
        }

        await refresh();
        return true;
      }

      _message = result.errorMessage;
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> deleteTransport(int id) async {
    try {
      final result = await _service.deleteTransport(id);

      if (result.isSuccess) {
        _allTransportsLoaded = false;
        await refresh();
      }

      return result.isSuccess;
    } finally {
      notifyListeners();
    }
  }

  Future<void> refreshTransports() async {
    _allTransportsLoaded = false;
    await refresh();
  }

  void clearDetails() {
    _transportDetails = null;
    notifyListeners();
  }
}
