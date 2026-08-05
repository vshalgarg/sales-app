// import 'package:flutter/material.dart';
// import '../model_classes/Transport/delete_transport.dart';
// import '../services/delete_transport_api.dart';
//
// class DeleteTransportProvider extends ChangeNotifier {
//
//   final DeleteTransportApi _api =
//   DeleteTransportApi();
//
//   bool _isLoading = false;
//
//   bool get isLoading => _isLoading;
//
//   DeleteTransport? _deleteResponse;
//
//   DeleteTransport? get deleteResponse =>
//       _deleteResponse;
//
//   String? _error;
//
//   String? get error => _error;
//
//   Future<void> deleteTransport(
//       int id) async {
//
//     _isLoading = true;
//
//     _error = null;
//
//     notifyListeners();
//
//     try {
//
//       final response =
//       await _api.deleteTransport(id);
//
//       _deleteResponse = response;
//
//     } catch (e) {
//
//       _error = e.toString();
//
//     } finally {
//
//       _isLoading = false;
//
//       notifyListeners();
//     }
//   }
// }