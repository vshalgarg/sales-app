import 'package:flutter/material.dart';
import 'package:hisabio/model_classes/get_staff_details_model.dart';
import 'package:hisabio/services/get_staff_api.dart';

class GetStaffProvider extends ChangeNotifier {

  bool isLoading = false;

  String? errorMessage;

  GetStaffDetailsModel? staffData;

  Future<void> getStaff() async {

    try {

      isLoading = true;

      errorMessage = null;

      notifyListeners();

      final response =
      await GetStaffApi().getStaff();

      staffData = response;

    } catch (e) {

      errorMessage = e.toString();

    } finally {

      isLoading = false;

      notifyListeners();
    }
  }
}