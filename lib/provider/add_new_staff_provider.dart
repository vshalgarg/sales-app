import 'package:flutter/material.dart';
import '../model_classes/add_newsupplier.dart';
import '../services/add_new_staff_api.dart';

class AddNewStaffProvider extends ChangeNotifier {

  final AddNewStaffApi _api = AddNewStaffApi();

  AddNewsupplier? addNewStaffResponse;

  bool isLoading = false;

  String? errorMessage;

  Future<void> addNewStaff(
      Map<String, dynamic> body,
      ) async {

    try {

      isLoading = true;

      errorMessage = null;

      notifyListeners();

      final response =
      await _api.addNewStaff(body);

      addNewStaffResponse = response;

    } catch (e) {

      errorMessage = e.toString();

    } finally {

      isLoading = false;

      notifyListeners();
    }
  }

  void clearData() {

    addNewStaffResponse = null;

    errorMessage = null;

    notifyListeners();
  }
}