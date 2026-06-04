import 'package:flutter/material.dart';
import '../model_classes/search_staff_model.dart';
import '../services/search_staff_api.dart';

class SearchStaffProvider extends ChangeNotifier {

  final GetSearchStaffApi _api = GetSearchStaffApi();

  SearchStaffModel? searchStaffModel;

  bool isLoading = false;

  String? errorMessage;

  Future<void> searchStaff(String keyword) async {

    try {

      isLoading = true;
      errorMessage = null;

      notifyListeners();

      final response = await _api.getSearchStaff(keyword);

      searchStaffModel = response;

    } catch (e) {

      errorMessage = e.toString();

    } finally {

      isLoading = false;

      notifyListeners();
    }
  }

  void clearSearch() {
    searchStaffModel = null;
    errorMessage = null;
    notifyListeners();
  }
}