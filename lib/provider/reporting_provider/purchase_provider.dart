import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../../model_classes/common/paginated_response.dart';
import '../../model_classes/entries/entries_supplier.dart';
import '../../model_classes/purchases/add_purchase_request.dart';
import '../../model_classes/purchases/get_purchase_model.dart';
import '../../model_classes/purchases/purchase.dart';
import '../../model_classes/purchases/purchase_details.dart' hide PurchaseDetails;
import '../../pagination/pagination_provider.dart';
import '../../services/purchase/purchase_service.dart';

class PurchaseProvider extends PaginationProvider<Purchase> {
  final PurchaseService _service;

  PurchaseProvider(this._service);

  PurchaseDetails? _purchaseDetails;

  bool _detailsLoading = false;
  bool _actionLoading = false;

  PurchaseDetails? get purchaseDetails => _purchaseDetails;

  bool get detailsLoading => _detailsLoading;

  bool get actionLoading => _actionLoading;

  String _searchKeyword = "";

  String? _fromDate;
  String? _toDate;
  int? _supplierId;
  int? _customerId;
  int? _staffId;

  void setFromDate(String? value) => _fromDate = value;

  void setToDate(String? value) => _toDate = value;

  void setSupplierId(int? value) => _supplierId = value;

  void setCustomerId(int? value) => _customerId = value;

  void setStaffId(int? value) => _staffId = value;
  @override
  Future<PaginatedResponse<Purchase>> requestPage({
    required int page,
    required int size,
  }) async {
    print("========== PURCHASE ==========");
    print("Requested page = $page");
    final result = await _service.searchPurchases(
      page: page,
      size: size,
      fromDate: _fromDate,
      toDate: _toDate,
      supplierId: _supplierId,
      customerId: _customerId,
      staffId: _staffId,
    );

    if (result.isFailure || result.data == null) {
      throw Exception(
        result.errorMessage ?? "Failed to load purchases",
      );
    }
    print("API page = ${result.data!.page}");
    print("Total pages = ${result.data!.totalPages}");
    print("Last = ${result.data!.last}");
    print("Items = ${result.data!.content.length}");
    return result.data!;
  }

  Future<bool> fetchPurchaseDetails(num id) async {
    _detailsLoading = true;
    notifyListeners();

    final result = await _service.getPurchaseDetails(id);

    _detailsLoading = false;

    if (result.isSuccess && result.data != null) {
      _purchaseDetails = result.data!.data as PurchaseDetails?;
    }

    notifyListeners();

    return result.isSuccess && result.data != null;
  }

  Future<bool> addPurchase({
    required AddPurchaseRequest request,
    required List<List<PlatformFile>> uploadedFiles,
    required List<EntriesModel?> selectedSuppliers,
  }) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.addPurchase(
        request: request,
        uploadedFiles: uploadedFiles,
        selectedSuppliers: selectedSuppliers,
      );

      if (result.isSuccess &&
          result.data != null &&
          result.data!.success) {
        await refreshPurchases();
        return true;
      }

      return false;

      return false;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }
  Future<bool> updatePurchase({
    required num id,
    required String date,
    required num customerId,
    required num supplierId,
    required num staffId,
    required String remarks,
    required List<String> existingImageKeys,
    required List<File> supplierImages,
  }) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.updatePurchase(
        id: id,
        date: date,
        customerId: customerId,
        supplierId: supplierId,
        staffId: staffId,
        remarks: remarks,
        existingImageKeys: existingImageKeys,
        supplierImages: supplierImages,
      );

      return result.isSuccess;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePurchase(num id) async {
    _actionLoading = true;
    notifyListeners();

    try {
      final result = await _service.deletePurchase(id);

      if (result.isSuccess) {
        await refreshPurchases();
      }

      return result.isSuccess;
    } finally {
      _actionLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPurchases() async {
    await refresh();
  }

  void clearDetails() {
    _purchaseDetails = null;
    notifyListeners();
  }
}

















// import 'package:flutter/material.dart';
// import '../model_classes/purchases/search_purchase.dart';
// import '../services/purchase_delete_api.dart' as purchaseApi;
// import '../services/search_purchase_api.dart';
// import '../shared_preferences/login_token.dart';
//
// class PurchaseProvider extends ChangeNotifier {
//   List<PurchaseEntry> _purchaseEntries = [];
//
//   List<PurchaseEntry> get purchaseEntries => _purchaseEntries;
//
//   bool _isLoading = false;
//   String? _successMessage;
//
//   String? get successMessage => _successMessage;
//
//   String? _errorMessage;
//
//   String? get errorMessage => _errorMessage;
//   bool get isLoading => _isLoading;
//
//   String? _error;
//
//   String? get error => _error;
//
//   int _page = 0;
//
//   int get page => _page;
//
//   int _size = 20;
//
//   int get size => _size;
//
//   int totalPages = 0;
//   bool last = false;
//
//   Future<void> searchPurchases({
//     int page = 0,
//     int size = 20,
//     bool isLoadMore = false,
//     String? fromDate,
//     String? toDate,
//     int? supplierId,
//     int? customerId,
//     int? staffId,
//   }) async {
//     print("searchPurchases called");
//     try {
//       if (!isLoadMore) {
//         _isLoading = true;
//         _error = null;
//        // notifyListeners();
//       }
//       print("API CALLED");
//       final response = await searchPurchaseEntries(
//         fromDate: fromDate,
//         toDate: toDate,
//         supplierId: supplierId,
//         customerId: customerId,
//         staffId: staffId,
//         page: page,
//         size: size,
//       );
//       for (final item in response.content) {
//         if (item.id == 43) {
//           print(
//             "Purchase 43 => "
//                 "Customer: ${item.customerName}, "
//                 "Supplier: ${item.supplierName}, "
//                 "Staff: ${item.staffName}",
//           );
//         }
//       }
//       if (isLoadMore) {
//         _purchaseEntries.addAll(response.content);
//       } else {
//         _purchaseEntries = response.content;
//       }
//
//       _page = response.page;
//       _size = size;
//       totalPages = response.totalPages;
//       last = response.last;
//     } catch (e) {
//       _error = e.toString();
//       debugPrint("Purchase Search Error: $e");
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<bool> deletePurchase(int id) async {
//     try {
//       _errorMessage = null;
//       _successMessage = null;
//
//       final token = await AppStorage.getToken();
//
//       if (token == null) {
//         throw Exception("Token not found");
//       }
//
//       final response = await purchaseApi.deletePurchase(
//         id,
//         token,
//       );
//
//       _purchaseEntries.removeWhere((e) => e.id == id);
//
//       _successMessage = response.message;
//
//       notifyListeners();
//
//       return true;
//     } catch (e) {
//       _errorMessage = e.toString().replaceFirst("Exception: ", "");
//
//       debugPrint("Delete Purchase Error => $e");
//
//       notifyListeners();
//
//       return false;
//     }
//   }
//   void clearSearch() {
//     _purchaseEntries.clear();
//     _error = null;
//     _page = 0;
//     totalPages = 0;
//     last = false;
//     notifyListeners();
//   }
// }
