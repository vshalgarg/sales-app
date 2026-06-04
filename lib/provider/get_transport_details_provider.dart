import 'package:flutter/material.dart';
import '../model_classes/get_transport_details.dart';
import '../services/get_transport_details_api.dart';

class GetTransportProvider extends ChangeNotifier {
  final GetTransportDetailsApi _api =
  GetTransportDetailsApi();

  GetTransport? transportData;

  bool isLoading = false;

  String? errorMessage;

  Future<void> getTransportDetails() async {
    try {
      isLoading = true;
      errorMessage = null;

      notifyListeners();

      transportData =
      await _api.getTransportDetails();

    } catch (e) {

      errorMessage = e.toString();

    } finally {

      isLoading = false;

      notifyListeners();
    }
  }
}