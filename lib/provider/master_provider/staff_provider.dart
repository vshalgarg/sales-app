
import 'package:flutter/cupertino.dart';
import 'package:hisabio/model_classes/staff/add_staff_request.dart';

import '../../../../model_classes/common/paginated_response.dart';
import '../../../../pagination/pagination_provider.dart';
import '../../model_classes/staff/staff.dart';
import '../../model_classes/staff/staff_details.dart';
import '../../services/staff/staff_service.dart';

class StaffProvider extends PaginationProvider<Staff> {
  final StaffService _service;
  bool _showLoader = true;
  StaffProvider(this._service);

  StaffDetails? _staffDetails;
  bool _detailsLoading = false;

  String _searchKeyword = "";

  // Controls the loader for the next pagination request.

  StaffDetails? get staffDetails => _staffDetails;
  bool get detailsLoading => _detailsLoading;

  Future<void> initializeStaff() async {
    _searchKeyword = "";
    _showLoader = true;
    clear();
    await fetchPage(0);
  }

  @override
  Future<PaginatedResponse<Staff>> requestPage({
    required int page,
    required int size,
  }) async {
    final result = _searchKeyword.isEmpty
        ? await _service.getStaffs(
      page: page,
      size: size,
      showLoader: _showLoader,
    )
        : await _service.searchStaffs(
      keyword: _searchKeyword,
      page: page,
      size: size,
      showLoader: _showLoader,
    );

    if (result.isFailure || result.data == null) {
      throw Exception(
        result.errorMessage ?? "Failed to load staff",
      );
    }

    return result.data!;
  }


  Future<void> search(String keyword) async {
    _searchKeyword = keyword.trim();
    await refreshStaffs();
  }

  void resetSearch() {
    _searchKeyword = "";
  }

  Future<void> clearSearch() async {
    _searchKeyword = "";
    await refreshStaffs();
  }

  // GET STAFF DETAILS
  Future<bool> fetchStaffDetails(
      int id, {
        bool showLoader = true,
      }) async {
    _detailsLoading = true;
    notifyListeners();

    try {
      final result = await _service.getStaffById(
        id,
        showLoader: showLoader,
      );

      if (result.isSuccess && result.data != null) {
        _staffDetails = result.data!;
        return true;
      }

      return false;
    } catch (e) {
      return false;
    } finally {
      _detailsLoading = false;
      notifyListeners();
    }
  }

  // ADD STAFF
  Future<bool> addStaff(AddStaffRequest request) async {
    notifyListeners();

    try {
      final result = await _service.addStaff(request);

      debugPrint("ADD STAFF ERROR: ${result.errorMessage}");

      if (result.isSuccess) {
        await refreshStaffs();
        return true;
      }

      return false;
    } finally {
      notifyListeners();
    }
  }

  // UPDATE STAFF
  Future<bool> updateStaff({
    required int id,
    required AddStaffRequest request,
  }) async {
    notifyListeners();

    try {
      final result = await _service.updateStaff(
        id: id,
        request: request,
      );

      if (result.isSuccess) {
        // Refresh staff list without global loader.
        //_showLoaderOnNextRequest = false;
        await refreshStaffs();

        // Refresh details without global loader.
        if (_staffDetails?.staffId == id) {
          await fetchStaffDetails(
            id,
            showLoader: false,
          );
        }

        return true;
      }

      return false;
    } finally {
      notifyListeners();
    }
  }

  // DELETE STAFF
  Future<bool> deleteStaff(int id) async {
    notifyListeners();

    try {
      final result = await _service.deleteStaff(id);

      if (result.isSuccess) {
        await refresh();
      }

      return result.isSuccess;
    } finally {
      notifyListeners();
    }
  }

  Future<void> refreshStaffs({bool showLoader = true}) async {
    _showLoader = showLoader;

    try {
      await refresh();
    } finally {
      _showLoader = true;
    }
  }
  void clearDetails() {
    _staffDetails = null;
    notifyListeners();
  }
}
