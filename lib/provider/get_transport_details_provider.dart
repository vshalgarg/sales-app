import 'package:flutter/material.dart';
import '../model_classes/get_transport_details.dart';
import '../services/get_transport_details_api.dart';

class GetTransportProvider extends ChangeNotifier {
  final GetTransportDetailsApi _api = GetTransportDetailsApi();

  final List<TransportContent> transports = [];

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;

  int _page = 0;
  final int _size = 10;

  String? errorMessage;

  Future<void> getTransportDetails({bool refresh = false}) async {
    if (isLoading || isLoadingMore) return;

    if (refresh) {
      _page = 0;
      transports.clear();
      hasMore = true;
      errorMessage = null;
    }

    if (!hasMore) return;

    if (_page == 0) {
      isLoading = true;
    } else {
      isLoadingMore = true;
    }

    notifyListeners();

    try {
      final response = await _api.getTransportDetails(
        page: _page,
        size: _size,
      );

      transports.addAll(response.content ?? []);

      hasMore = !(response.last ?? true);

      if (hasMore) {
        _page++;
      }

      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshTransport() async {
    await getTransportDetails(refresh: true);
  }
}