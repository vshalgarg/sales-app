import 'package:flutter/material.dart';
import '../model_classes/get_customer_byid_model.dart';
import '../services/get_customer_byid.dart';

class GetCustomerByIdProvider extends ChangeNotifier {

  final GeCustomersByIdApi _api = GeCustomersByIdApi();

  GetCustomerByidModel? customer;

  bool isLoading = false;

  String? errorMessage;

  Future<void> getCustomerById(int id) async {

    try {

      isLoading = true;
      errorMessage = null;

      notifyListeners();

      final response = await _api.getCustomerById(id);

      customer = response;

    } catch (e) {

      errorMessage = e.toString();

    } finally {

      isLoading = false;

      notifyListeners();
    }
  }
}