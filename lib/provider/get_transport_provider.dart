import 'package:flutter/material.dart';
import 'package:hisabio/model_classes/get_transports_model.dart';
import 'package:hisabio/services/get_tranports.dart';

class TransportProvider with ChangeNotifier {
  final GetTransportApi _api = GetTransportApi();

  List<GetTransportsModel> _transports = [];
  List<GetTransportsModel> get transports => _transports;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchTransports() async {
    _isLoading = true;
    notifyListeners();

    try {
      _transports = await _api.getTransport();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}