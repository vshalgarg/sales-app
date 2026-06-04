import 'package:flutter/material.dart';
import '../model_classes/update_staff_model.dart';
import '../services/update_staff_api.dart';

class UpdateStaffProvider extends ChangeNotifier {

  final UpdateStaffApi _api = UpdateStaffApi();

  UpdateStaffModel? updateStaffResponse;

  bool isLoading = false;

  String? errorMessage;

  Future<void> updateStaff({
    required Map<String, dynamic> body,
    required int id,
  }) async {

    try {

      isLoading = true;

      errorMessage = null;

      notifyListeners();

      final response = await _api.updateStaff(
        body: body,
        id: id,
      );

      updateStaffResponse = response;

    } catch (e) {

      errorMessage = e.toString();

    } finally {

      isLoading = false;

      notifyListeners();
    }
  }

  void clearData() {

    updateStaffResponse = null;

    errorMessage = null;

    notifyListeners();
  }
}