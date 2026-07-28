import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hisabio/model_classes/entries_customer_model.dart';
import 'package:hisabio/model_classes/entries_supplier.dart';
import 'package:hisabio/model_classes/get_transportname_id_model.dart';

import '../../model_classes/add_newsupplier.dart';
import '../../model_classes/creditdetails_byid.dart';
import '../../model_classes/get_staff_entry.dart';
import '../../services/add_supplier.dart';
import '../../services/entries_services/entries_api.dart';

class EntriesProvider extends ChangeNotifier {
  final EntriesApi _api = EntriesApi();

  List<EntriesModel> _entries = [];
  CreditDetailsResponse? _creditDetails;
  CreditDetailsResponse? get creditDetails => _creditDetails;
  List<EntriesModel> get entries => _entries;
  List<EntriesCustomerModel>_customerEntries=[];
  List<GetTransportnameIdModel> _transport=[];
  List<GetTransportnameIdModel> get transportDetails=>_transport;
  List<EntriesCustomerModel> get customerEntries=>_customerEntries;
  bool _isLoading = false;
  String? _error;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<GetStaffEntry> staffEntries = [];
  final AddSupplierApi _addSupplierApi = AddSupplierApi();
  List<GetStaffEntry> get staffList => staffEntries;
  bool _disposed = false;

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
  Future<void> fetchSuppliers() async {
    try {
      _entries = await _api.getEntrySupplier();
      safeNotify();
    } catch (e) {
      _error = e.toString();
      safeNotify();
    }
  }
  // Future<void> fetchSuppliers() async {
  //   _isLoading = true;
  //   _error = null;
  //   notifyListeners();
  //   try {
  //     _entries = await _api.getEntrySupplier();
  //   } catch (e) {
  //     _error = e.toString();
  //   }
  //
  //   _isLoading = false;
  //   notifyListeners();
  // }
  Future<void> fetchCustomer() async {
    try {
      _customerEntries = await _api.getEntryCustomer();
      safeNotify();
    } catch (e) {
      _error = e.toString();
      safeNotify();
    }
  }
  // Future<void> fetchCustomer() async {
  //   _isLoading = true;
  //   _error = null;
  //   notifyListeners();
  //
  //   try {
  //     _customerEntries=await _api.getEntryCustomer();
  //   } catch (e) {
  //     _error = e.toString();
  //   }
  //
  //   _isLoading = false;
  //   notifyListeners();
  // }
  Future<void> fetchTransport() async {
    try {
      _transport =
      await _api.getTransporters();
    } catch (e) {
      _error = e.toString();
    }
  }
  // Future<void> fetchTransport() async {
  //   _isLoading = true;
  //   _error = null;
  //   notifyListeners();
  //
  //   try {
  //     _transport=await _api.getTransporters();
  //   } catch (e) {
  //     _error = e.toString();
  //   }
  //
  //   _isLoading = false;
  //   notifyListeners();
  // }
  Future<String> addSupplier(Map<String, dynamic> body) async {
    try {
      _isLoading = true;
      safeNotify();

      return await _addSupplierApi.addSupplier(body);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      safeNotify();
    }
  }
  void clear() {
    //_entries = null;
    _error = null;
    safeNotify();
  }
  Future<AddNewsupplier?> addCreditEntry(
      Map<String, dynamic> body) async {
    try {
      _isLoading = true;
      _error = null;
      safeNotify();

      final response = await _api.addNewCreditEntry(body);

      return response;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      safeNotify();
    }
  }
  Future<String?> saveBill({
    required Map<String, dynamic> payload,
    required List<File> images,
  }) async {
    return await _api.addBillEntry(
      payload: payload,
      images: images,
    );
  }
  Future<String?> savePurchase({
    required Map<String, dynamic> payload,
    required List<List<PlatformFile>> uploadedFiles,
    required List<EntriesModel?>selectedSuppliers
  }) async {
    return await _api.addPurchaseEntry(
      payload: payload,
      uploadedFiles:uploadedFiles,
      selectedSuppliers:selectedSuppliers,
    );
  }
  Future<void> fetchStaff() async {
    try {
      staffEntries = await EntriesApi().getStaffEntry();
      safeNotify();

    } catch (e) {
      rethrow;
    }
  }
  Future<String?> addRetailEntry(
      Map<String, dynamic> body) async {
    try {
      _isLoading = true;
      _error = null;
      safeNotify();

      final response = await _api.addNewRetailEntry(body);

      return response;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      safeNotify();
    }
  }
  Future<String?> updateBillEntry({
    required int id,
    required Map<String, dynamic> payload,
    required List<File> images,
  }) async {
    _isLoading = true;
    _error = null;
    safeNotify();

    try {
      final message = await _api.updateBillEntry(
        id: id,
        payload: payload,
        images: images,
      );

      _isLoading = false;
      safeNotify();

      return message;
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
      _isLoading = false;
      safeNotify();
      rethrow;
    }
  }
  Future<void> getCreditDetailsById(int id) async {
    _isLoading = true;
    _error = null;
    safeNotify();

    try {
      _creditDetails = await _api.getCreditDetailsById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      safeNotify();
    }
  }
  Future<void> loadInitialData() async {
    _isLoading = true;
    _error = null;
    safeNotify();

    try {
      _entries = await _api.getEntrySupplier();
      _customerEntries = await _api.getEntryCustomer();
      _transport = await _api.getTransporters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      safeNotify();
    }
  }
  Future<AddNewsupplier?> updateCreditDetails({
    required Map<String, dynamic> body,
    required int id,
  }) async {
    _isLoading = true;
    //_error = null;
    safeNotify();
    try {
      final response = await _api.updateCreditDetails(
        body: body,
        id: id,
      );
      safeNotify();
      return response;
    } catch (e) {
      throw Exception(e.toString());
    } finally{
      _isLoading = false;
      safeNotify();
    }
  }
}