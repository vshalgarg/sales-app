import 'package:flutter/material.dart';
import 'package:hisabio/model_classes/delete_staff.dart';
import 'package:hisabio/services/delete_staff_api.dart';

class DeleteStaffProvider extends ChangeNotifier {

  bool isLoading = false;

  String? errorMessage;

  DeleteStaff? deleteStaffResponse;

  Future<void> deleteStaff(
      Map<String, dynamic> body,
      ) async {

    try {

      isLoading = true;

      errorMessage = null;

      notifyListeners();

      final response =
      await DeleteStaffApi()
          .deleteStaff(body);

      deleteStaffResponse = response;

    } catch (e) {

      errorMessage = e.toString();

    } finally {

      isLoading = false;

      notifyListeners();
    }
  }
}