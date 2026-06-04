import 'package:flutter/material.dart';
import '../model_classes/get_staff_by_id_model.dart';
import '../services/get_staff_byid_api.dart';

class GetStaffByIdProvider extends ChangeNotifier {

  final GetStaffByIdApi _api = GetStaffByIdApi();

  GetStaffByIdModel? staffData;

  bool isLoading = false;

  String? errorMessage;

  Future<void> getStaffById(int id) async {

    try {

      isLoading = true;

      errorMessage = null;

      notifyListeners();

      final response =
      await _api.getStaffById(id);

      staffData = response;

    } catch (e) {

      errorMessage = e.toString();

    } finally {

      isLoading = false;

      notifyListeners();
    }
  }

  void clearData() {

    staffData = null;

    errorMessage = null;

    notifyListeners();
  }
}