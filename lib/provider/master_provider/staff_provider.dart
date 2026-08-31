import 'package:hisabio/model_classes/staff/add_staff_request.dart';
import '../../../../model_classes/common/paginated_response.dart';
import '../../../../pagination/pagination_provider.dart';
import '../../model_classes/staff/staff.dart';
import '../../model_classes/staff/staff_details.dart';
import '../../services/staff/staff_service.dart';

class StaffProvider extends PaginationProvider<Staff> {
  final StaffService _service;

  StaffProvider(this._service);

  StaffDetails? _staffDetails;

  bool _detailsLoading = false;

  String _searchKeyword = "";

  StaffDetails? get staffDetails => _staffDetails;

  bool get detailsLoading => _detailsLoading;

  @override
  Future<PaginatedResponse<Staff>> requestPage({
    required int page,
    required int size,
  }) async {
    final result = _searchKeyword.isEmpty
        ? await _service.getStaffs(
      page: page,
      size: size,
    )
        : await _service.searchStaffs(
      keyword: _searchKeyword,
      page: page,
      size: size,
    );

    if (result.isFailure || result.data == null) {
      throw Exception(result.errorMessage ?? "Failed to load staff");
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

  Future<bool> fetchStaffDetails(int id) async {
    _detailsLoading = true;
    notifyListeners();

    final result = await _service.getStaffById(id);

    _detailsLoading = false;

    if (result.isSuccess && result.data != null) {
      _staffDetails = result.data!;
    }

    notifyListeners();

    return result.isSuccess && result.data != null;
  }

  Future<bool> addStaff(AddStaffRequest request) async {
    notifyListeners();

    try {
      final result = await _service.addStaff(request);

      print("ADD STAFF REQUEST: ${request.toJson()}");
      print("ADD STAFF SUCCESS: ${result.isSuccess}");
      print("ADD STAFF ERROR: ${result.errorMessage}");

      if (result.isSuccess) {
        await refreshStaffs();
        return true;
      }

      return false;
    } finally {
      notifyListeners();
    }
  }

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
        await refreshStaffs();

        if (_staffDetails?.staffId == id) {
          await fetchStaffDetails(id);
        }

        return true;
      }

      return false;
    } finally {

      notifyListeners();
    }
  }

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

  Future<void> refreshStaffs() async {
    await refresh();
  }

  void clearDetails() {
    _staffDetails = null;
    notifyListeners();
  }
}