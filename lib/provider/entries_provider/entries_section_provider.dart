import 'package:flutter/material.dart';
import 'package:hisabio/model_classes/entries_customer_model.dart';
import 'package:hisabio/model_classes/entries_supplier.dart';
import 'package:hisabio/model_classes/get_transportname_id_model.dart';

import '../../services/entries_services/entries_api.dart';

class EntriesProvider extends ChangeNotifier {
  final EntriesApi _api = EntriesApi();

  List<EntriesModel> _entries = [];

  List<EntriesModel> get entries => _entries;
  List<EntriesCustomerModel>_customerEntries=[];
  List<GetTransportnameIdModel> _transport=[];
  List<GetTransportnameIdModel> get transportDetails=>_transport;
  List<EntriesCustomerModel> get customerEntries=>_customerEntries;
  bool _isLoading = false;
  String? _error;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSuppliers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _entries = await _api.getEntrySupplier();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
  Future<void> fetchCustomer() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _customerEntries=await _api.getEntryCustomer();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
  Future<void> fetchTransport() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transport=await _api.getTransporters();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    //_entries = null;
    _error = null;
    notifyListeners();
  }
}