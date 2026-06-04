import 'package:flutter/material.dart';
import '../model_classes/add_transport_model.dart';
import '../services/add_transport_api.dart';

class AddNewTransportProvider extends ChangeNotifier {

  final AddNewTransportApi _api =
  AddNewTransportApi();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  AddTransportModel? _response;

  AddTransportModel? get response =>
      _response;

  String? _error;

  String? get error => _error;

  Future<void> addNewTransport(
      Map<String, dynamic> body,
      ) async {

    _isLoading = true;

    _error = null;

    notifyListeners();

    try {

      final result =
      await _api.addNewTransport(body);

      _response = result;

    } catch (e) {

      _error = e.toString();

    } finally {

      _isLoading = false;

      notifyListeners();
    }
  }
}