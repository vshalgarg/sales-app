import 'package:flutter/material.dart';

import '../model_classes/staff_model.dart';
import '../services/get_all_staff_api.dart';

class StaffProvider extends ChangeNotifier {
  bool isLoading = false;

  String? errorMessage;

  List<StaffModel> staffs = [];

  Future<void> fetchStaffs() async {
    try {
      isLoading = true;
      errorMessage = null;

      notifyListeners();

      staffs = await GetAllStaffApi().getStaffs();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }
}
