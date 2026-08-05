// import 'package:flutter/material.dart';
//
// import '../model_classes/Transport/get_transport_by_id.dart';
// import '../services/get_transport_by_id.dart';
//
// class GetTransportByIdProvider extends ChangeNotifier {
//   final GetTransportByIdApi _api = GetTransportByIdApi();
//
//   bool _isLoading = false;
//
//   bool get isLoading => _isLoading;
//
//   GetTransportById? _transport;
//
//   GetTransportById? get transport => _transport;
//
//   String? _error;
//
//   String? get error => _error;
//
//   Future<void> getTransportById(int id) async {
//     _isLoading = true;
//
//     _error = null;
//
//     notifyListeners();
//
//     try {
//       final result = await _api.getTransportById(id);
//
//       _transport = result;
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//
//       notifyListeners();
//     }
//   }
//
//   void clearTransport() {
//     _transport = null;
//
//     notifyListeners();
//   }
// }
