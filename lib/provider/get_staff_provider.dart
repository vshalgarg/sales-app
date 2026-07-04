import 'package:flutter/material.dart';
import 'package:hisabio/model_classes/get_staff_details_model.dart';
import 'package:hisabio/services/get_staff_api.dart';

class GetStaffProvider extends ChangeNotifier {
  final List<Content> staffs = [];

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;

  int _page = 0;
  final int _size = 10;

  String? errorMessage;

  Future<void> getStaff({bool refresh = false}) async {
    if (isLoading || isLoadingMore) return;

    if (refresh) {
      _page = 0;
      staffs.clear();
      hasMore = true;
      errorMessage = null;
    }

    if (!hasMore) return;

    if (_page == 0) {
      isLoading = true;
    } else {
      isLoadingMore = true;
    }

    notifyListeners();

    try {
      final response = await GetStaffApi().getStaff(
        page: _page,
        size: _size,
      );

      final List<Content> newStaffs = response.content ?? [];

      staffs.addAll(newStaffs);

      hasMore = !(response.last ?? true);

      if (hasMore) {
        _page++;
      }

      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshStaff() async {
    await getStaff(refresh: true);
  }
}