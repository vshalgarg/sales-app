// import 'package:flutter/material.dart';
//
// import '../model_classes/Transport/search_transport_model.dart';
// import '../services/search_transport_api.dart';
//
// class SearchTransportProvider extends ChangeNotifier {
//   final GetSearchTransportApi _api = GetSearchTransportApi();
//
//   bool _isLoading = false;
//
//   bool get isLoading => _isLoading;
//
//   SearchTransportModel? _response;
//
//   SearchTransportModel? get response => _response;
//
//   String? _error;
//
//   String? get error => _error;
//
//   Future<void> getSearchTransport(String keyword) async {
//     _isLoading = true;
//
//     _error = null;
//
//     notifyListeners();
//
//     try {
//       final result = await _api.getSearchTransport(keyword);
//
//       _response = result;
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//
//       notifyListeners();
//     }
//   }
// }
