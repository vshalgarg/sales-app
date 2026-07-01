import 'package:flutter/material.dart';

import '../model_classes/get_ledger_details.dart';
import '../services/get_ledger_details_services.dart';

class GetLedgerDetailsProvider extends ChangeNotifier {
  final GetLedgerDetailsServices _service = GetLedgerDetailsServices();

  GetLedgerDetails? _ledgerDetails;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasSearched = false;

  bool get hasSearched => _hasSearched;

  GetLedgerDetails? get ledgerDetails => _ledgerDetails;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> getLedgerDetails(
      int supplierId,
      int customerId,
      String viewType,
      ) async {
    _hasSearched = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ledgerDetails = await _service.getLedgerDetails(
        supplierId,
        customerId,
        viewType,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearLedger() {
    _ledgerDetails = null;
    _errorMessage = null;
    _hasSearched = false;
    notifyListeners();
  }
}