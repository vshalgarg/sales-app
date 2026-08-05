import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../model_classes/Transport/transport.dart';
import '../../model_classes/common/api_response.dart';
import '../../model_classes/credits/creditdetails_byid.dart';
import '../../model_classes/entries/add_newsupplier.dart';
import '../../model_classes/entries/entries_customer_model.dart';
import '../../model_classes/entries/entries_supplier.dart';
import '../../model_classes/entries/get_staff_entry.dart';
import '../../services/entries_services/entries_service.dart';

class EntriesProvider extends ChangeNotifier {
  final EntriesService _service;

  EntriesProvider(this._service);

  List<EntriesModel> _entries = [];

  List<EntriesCustomerModel> _customerEntries = [];

  List<Transport> _transport = [];

  List<GetStaffEntry> _staffEntries = [];

  ApiResponse? _creditDetails;

  bool _loading = false;

  String? _error;

  bool _disposed = false;

  List<EntriesModel> get entries => _entries;

  List<EntriesCustomerModel> get customerEntries =>
      _customerEntries;

  List<Transport> get transportDetails => _transport;

  List<GetStaffEntry> get staffList => _staffEntries;

  ApiResponse? get creditDetails =>
      _creditDetails;

  bool get isLoading => _loading;

  String? get error => _error;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void safeNotify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  ///---------------------------------------------------------------
  /// FETCH SUPPLIERS
  ///---------------------------------------------------------------

  Future<void> fetchSuppliers() async {
    final result = await _service.fetchSuppliers();

    if (result.isSuccess && result.data != null) {
      _entries = result.data!;
      _error = null;
    } else {
      _error = result.errorMessage;
    }

    safeNotify();
  }

  ///---------------------------------------------------------------
  /// FETCH CUSTOMERS
  ///---------------------------------------------------------------

  Future<void> fetchCustomer() async {
    final result =
    await _service.fetchCustomers();

    if (result.isSuccess && result.data != null) {
      _customerEntries = result.data!;
      _error = null;
    } else {
      _error = result.errorMessage;
    }

    safeNotify();
  }

  ///---------------------------------------------------------------
  /// FETCH TRANSPORT
  ///---------------------------------------------------------------

  Future<void> fetchTransport() async {
    final result =
    await _service.fetchTransports();

    if (result.isSuccess && result.data != null) {
      _transport = result.data!;
      _error = null;
    } else {
      _error = result.errorMessage;
    }

    safeNotify();
  }

  ///---------------------------------------------------------------
  /// FETCH STAFF
  ///---------------------------------------------------------------

  Future<void> fetchStaff() async {
    final result =
    await _service.fetchStaff();

    if (result.isSuccess && result.data != null) {
      _staffEntries = result.data!;
      _error = null;
    } else {
      _error = result.errorMessage;
    }

    safeNotify();
  }
  ///---------------------------------------------------------------
  /// ADD SUPPLIER
  ///---------------------------------------------------------------

  Future<bool> addSupplier(
      Map<String, dynamic> body,
      ) async {
    _loading = true;
    _error = null;
    safeNotify();

    try {
      final result = await _service.addSupplier(
        body: body,
      );

      if (result.isSuccess) {
        await fetchSuppliers();
        return true;
      }

      _error = result.errorMessage;
      return false;
    } finally {
      _loading = false;
      safeNotify();
    }
  }

  ///---------------------------------------------------------------
  /// ADD CREDIT ENTRY
  ///---------------------------------------------------------------

  Future<AddNewsupplier?> addCreditEntry(
      Map<String, dynamic> body,
      ) async {
    _loading = true;
    _error = null;
    safeNotify();

    try {
      final result = await _service.addCreditEntry(
        body: body,
      );

      if (result.isSuccess) {
        return result.data;
      }

      _error = result.errorMessage;
      return null;
    } finally {
      _loading = false;
      safeNotify();
    }
  }

  ///---------------------------------------------------------------
  /// ADD RETAIL ENTRY
  ///---------------------------------------------------------------

  Future<bool> addRetailEntry(
      Map<String, dynamic> body,
      ) async {
    _loading = true;
    _error = null;
    safeNotify();

    try {
      final result = await _service.addRetailEntry(
        body: body,
      );

      if (result.isSuccess) {
        return true;
      }

      _error = result.errorMessage;
      return false;
    } finally {
      _loading = false;
      safeNotify();
    }
  }

  ///---------------------------------------------------------------
  /// CLEAR
  ///---------------------------------------------------------------

  void clear() {
    _error = null;
    safeNotify();
  }
  ///---------------------------------------------------------------
  /// SAVE BILL
  ///---------------------------------------------------------------

  Future<bool> saveBill({
    required Map<String, dynamic> payload,
    required List<File> images,
  }) async {
    _loading = true;
    _error = null;
    safeNotify();

    try {
      final result = await _service.addBill(
        payload: payload,
        images: images,
      );

      if (result.isSuccess) {
        return true;
      }

      _error = result.errorMessage;
      return false;
    } finally {
      _loading = false;
      safeNotify();
    }
  }

  ///---------------------------------------------------------------
  /// UPDATE BILL
  ///---------------------------------------------------------------

  Future<bool> updateBillEntry({
    required int id,
    required Map<String, dynamic> payload,
    required List<File> images,
  }) async {
    _loading = true;
    _error = null;
    safeNotify();

    try {
      final result = await _service.updateBill(
        id: id,
        payload: payload,
        images: images,
      );

      if (result.isSuccess) {
        return true;
      }

      _error = result.errorMessage;
      return false;
    } finally {
      _loading = false;
      safeNotify();
    }
  }

  ///---------------------------------------------------------------
  /// SAVE PURCHASE
  ///---------------------------------------------------------------

  Future<bool> savePurchase({
    required Map<String, dynamic> payload,
    required List<List<PlatformFile>> uploadedFiles,
    required List<EntriesModel?> selectedSuppliers,
  }) async {
    _loading = true;
    _error = null;
    safeNotify();

    try {
      final result = await _service.addPurchase(
        payload: payload,
        uploadedFiles: uploadedFiles,
        selectedSuppliers: selectedSuppliers,
      );

      if (result.isSuccess) {
        return true;
      }

      _error = result.errorMessage;
      return false;
    } finally {
      _loading = false;
      safeNotify();
    }
  }
  ///---------------------------------------------------------------
  /// GET CREDIT DETAILS
  ///---------------------------------------------------------------

  Future<bool> getCreditDetailsById(int id) async {
    _loading = true;
    _error = null;
    safeNotify();

    try {
      final result =
      await _service.getCreditDetailsById(id);

      if (result.isSuccess && result.data != null) {
        _creditDetails = result.data;
        return true;
      }

      _error = result.errorMessage;
      return false;
    } finally {
      _loading = false;
      safeNotify();
    }
  }

  ///---------------------------------------------------------------
  /// UPDATE CREDIT DETAILS
  ///---------------------------------------------------------------

  Future<AddNewsupplier?> updateCreditDetails({
    required Map<String, dynamic> body,
    required int id,
  }) async {
    _loading = true;
    _error = null;
    safeNotify();

    try {
      final result =
      await _service.updateCreditDetails(
        id: id,
        body: body,
      );

      if (result.isSuccess) {
        return result.data;
      }

      _error = result.errorMessage;
      return null;
    } finally {
      _loading = false;
      safeNotify();
    }
  }

  ///---------------------------------------------------------------
  /// LOAD INITIAL DATA
  ///---------------------------------------------------------------

  Future<void> loadInitialData() async {
    _loading = true;
    _error = null;
    safeNotify();

    try {
      await Future.wait([
        fetchSuppliers(),
        fetchCustomer(),
        fetchTransport(),
        fetchStaff(),
      ]);
    } finally {
      _loading = false;
      safeNotify();
    }
  }
}











// import 'dart:io';
//
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:hisabio/model_classes/Transport/transport.dart';
// import 'package:hisabio/model_classes/Transport/transport_details.dart';
// import 'package:hisabio/model_classes/entries/entries_customer_model.dart';
// import 'package:hisabio/model_classes/entries/entries_supplier.dart';
// import 'package:hisabio/model_classes/Transport/get_transportname_id_model.dart';
//
// import '../../model_classes/entries/add_newsupplier.dart';
// import '../../model_classes/credits/creditdetails_byid.dart';
// import '../../model_classes/entries/get_staff_entry.dart';
// import '../../services/add_supplier.dart';
// import '../../services/entries_services/entries_service.dart';
//
// class EntriesProvider extends ChangeNotifier {
//   final EntriesService _api = EntriesApi();
//   final AddSupplierApi _addSupplierApi;
//   List<EntriesModel> _entries = [];
//   CreditDetailsResponse? _creditDetails;
//   CreditDetailsResponse? get creditDetails => _creditDetails;
//   List<EntriesModel> get entries => _entries;
//   List<EntriesCustomerModel>_customerEntries=[];
//   List<Transport> _transport=[];
//   List<Transport> get transportDetails=>_transport;
//   List<EntriesCustomerModel> get customerEntries=>_customerEntries;
//   bool _isLoading = false;
//   String? _error;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   List<GetStaffEntry> staffEntries = [];
//  // final AddSupplierApi _addSupplierApi = AddSupplierApi();
//   List<GetStaffEntry> get staffList => staffEntries;
//   bool _disposed = false;
//   EntriesProvider({
//     required AddSupplierApi addSupplierApi,
//   }) : _addSupplierApi = addSupplierApi;
//   @override
//   void dispose() {
//     _disposed = true;
//     super.dispose();
//   }
//
//   void safeNotify() {
//     if (!_disposed) {
//       notifyListeners();
//     }
//   }
//   Future<void> fetchSuppliers() async {
//     try {
//       _entries = await _api.getEntrySupplier();
//       safeNotify();
//     } catch (e) {
//       _error = e.toString();
//       safeNotify();
//     }
//   }
//   // Future<void> fetchSuppliers() async {
//   //   _isLoading = true;
//   //   _error = null;
//   //   notifyListeners();
//   //   try {
//   //     _entries = await _api.getEntrySupplier();
//   //   } catch (e) {
//   //     _error = e.toString();
//   //   }
//   //
//   //   _isLoading = false;
//   //   notifyListeners();
//   // }
//   Future<void> fetchCustomer() async {
//     try {
//       _customerEntries = await _api.getEntryCustomer();
//       safeNotify();
//     } catch (e) {
//       _error = e.toString();
//       safeNotify();
//     }
//   }
//   // Future<void> fetchCustomer() async {
//   //   _isLoading = true;
//   //   _error = null;
//   //   notifyListeners();
//   //
//   //   try {
//   //     _customerEntries=await _api.getEntryCustomer();
//   //   } catch (e) {
//   //     _error = e.toString();
//   //   }
//   //
//   //   _isLoading = false;
//   //   notifyListeners();
//   // }
//   Future<void> fetchTransport() async {
//     try {
//       _transport =
//       await _api.getTransporters();
//     } catch (e) {
//       _error = e.toString();
//     }
//   }
//   // Future<void> fetchTransport() async {
//   //   _isLoading = true;
//   //   _error = null;
//   //   notifyListeners();
//   //
//   //   try {
//   //     _transport=await _api.getTransporters();
//   //   } catch (e) {
//   //     _error = e.toString();
//   //   }
//   //
//   //   _isLoading = false;
//   //   notifyListeners();
//   // }
//   Future<String> addSupplier(Map<String, dynamic> body) async {
//     try {
//       _isLoading = true;
//       safeNotify();
//
//       return await _addSupplierApi.addSupplier(body);
//     } catch (e) {
//       rethrow;
//     } finally {
//       _isLoading = false;
//       safeNotify();
//     }
//   }
//   void clear() {
//     //_entries = null;
//     _error = null;
//     safeNotify();
//   }
//   Future<AddNewsupplier?> addCreditEntry(
//       Map<String, dynamic> body) async {
//     try {
//       _isLoading = true;
//       _error = null;
//       safeNotify();
//
//       final response = await _api.addNewCreditEntry(body);
//
//       return response;
//     } catch (e) {
//       _error = e.toString();
//       rethrow;
//     } finally {
//       _isLoading = false;
//       safeNotify();
//     }
//   }
//   Future<String?> saveBill({
//     required Map<String, dynamic> payload,
//     required List<File> images,
//   }) async {
//     return await _api.addBillEntry(
//       payload: payload,
//       images: images,
//     );
//   }
//   Future<String?> savePurchase({
//     required Map<String, dynamic> payload,
//     required List<List<PlatformFile>> uploadedFiles,
//     required List<EntriesModel?>selectedSuppliers
//   }) async {
//     return await _api.addPurchaseEntry(
//       payload: payload,
//       uploadedFiles:uploadedFiles,
//       selectedSuppliers:selectedSuppliers,
//     );
//   }
//   Future<void> fetchStaff() async {
//     try {
//       staffEntries = await EntriesApi().getStaffEntry();
//       safeNotify();
//
//     } catch (e) {
//       rethrow;
//     }
//   }
//   Future<String?> addRetailEntry(
//       Map<String, dynamic> body) async {
//     try {
//       _isLoading = true;
//       _error = null;
//       safeNotify();
//
//       final response = await _api.addNewRetailEntry(body);
//
//       return response;
//     } catch (e) {
//       _error = e.toString();
//       rethrow;
//     } finally {
//       _isLoading = false;
//       safeNotify();
//     }
//   }
//   Future<String?> updateBillEntry({
//     required int id,
//     required Map<String, dynamic> payload,
//     required List<File> images,
//   }) async {
//     _isLoading = true;
//     _error = null;
//     safeNotify();
//
//     try {
//       final message = await _api.updateBillEntry(
//         id: id,
//         payload: payload,
//         images: images,
//       );
//
//       _isLoading = false;
//       safeNotify();
//
//       return message;
//     } catch (e) {
//       _error = e.toString().replaceFirst("Exception: ", "");
//       _isLoading = false;
//       safeNotify();
//       rethrow;
//     }
//   }
//   Future<void> getCreditDetailsById(int id) async {
//     _isLoading = true;
//     _error = null;
//     safeNotify();
//
//     try {
//       _creditDetails = await _api.getCreditDetailsById(id);
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       safeNotify();
//     }
//   }
//   Future<void> loadInitialData() async {
//     _isLoading = true;
//     _error = null;
//     safeNotify();
//
//     try {
//       _entries = await _api.getEntrySupplier();
//       _customerEntries = await _api.getEntryCustomer();
//       _transport = await _api.getTransporters();
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       safeNotify();
//     }
//   }
//   Future<AddNewsupplier?> updateCreditDetails({
//     required Map<String, dynamic> body,
//     required int id,
//   }) async {
//     _isLoading = true;
//     //_error = null;
//     safeNotify();
//     try {
//       final response = await _api.updateCreditDetails(
//         body: body,
//         id: id,
//       );
//       safeNotify();
//       return response;
//     } catch (e) {
//       throw Exception(e.toString());
//     } finally{
//       _isLoading = false;
//       safeNotify();
//     }
//   }
// }