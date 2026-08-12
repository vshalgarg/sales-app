import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../model_classes/Transport/transport.dart';
import '../../model_classes/common/api_response.dart';
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

  // FETCH SUPPLIERS

  Future<void> fetchSuppliers({bool forceRefresh = false}) async {
    if (!forceRefresh && _entries.isNotEmpty) {
      return; // Already loaded
    }

    final result = await _service.fetchSuppliers();

    if (result.isSuccess && result.data != null) {
      _entries = result.data!;
      _error = null;
    } else {
      _error = result.errorMessage;
    }

    safeNotify();
  }

  // FETCH CUSTOMERS

  Future<void> fetchCustomer({bool forceRefresh = false}) async {
    if (!forceRefresh && _customerEntries.isNotEmpty) {
      return; // Already loaded
    }

    final result = await _service.fetchCustomers();

    if (result.isSuccess && result.data != null) {
      _customerEntries = result.data!;
      _error = null;
    } else {
      _error = result.errorMessage;
    }

    safeNotify();
  }

  // FETCH TRANSPORT

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

  // FETCH STAFF

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
  // ADD SUPPLIER

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

  // ADD CREDIT ENTRY

  Future<AddNewSupplier?> addCreditEntry(
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

  // ADD RETAIL ENTRY

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

  // CLEAR

  void clear() {
    _error = null;
    safeNotify();
  }
  // SAVE BILL

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

  // UPDATE BILL

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

  // SAVE PURCHASE

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
  // GET CREDIT DETAILS

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

  // UPDATE CREDIT DETAILS

  Future<AddNewSupplier?> updateCreditDetails({
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

  // LOAD INITIAL DATA

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
