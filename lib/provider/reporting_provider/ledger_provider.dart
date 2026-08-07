import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../model_classes/get_ledger_details.dart';
import '../../services/ledger/ledger_service.dart';

class LedgerProvider extends ChangeNotifier {
  final LedgerService _service;

  LedgerProvider(this._service);
  bool _hasSearched = false;

  bool get hasSearched => _hasSearched;
  LedgerData? _ledger;

  bool _loading = false;
  bool _downloading = false;

  LedgerData? get ledger => _ledger;

  bool get loading => _loading;

  bool get downloading => _downloading;

  Future<bool> fetchLedger({
    required num supplierId,
    required num customerId,
    required String viewType,

  }) async {
    _loading = true;
    notifyListeners();

    try {
      final result = await _service.getLedger(
        supplierId: supplierId,
        customerId: customerId,
        viewType: viewType,
      );

      if (result.isSuccess && result.data != null) {
        _ledger = result.data!.data as LedgerData?;
        return true;
      }

      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Uint8List?> downloadLedger({
    required num supplierId,
    required num customerId,
    required String viewType,
  }) async {
    _downloading = true;
    notifyListeners();

    try {
      final result = await _service.downloadLedger(
        supplierId: supplierId,
        customerId: customerId,
        viewType: viewType,
      );

      if (result.isSuccess) {
        return result.data;
      }

      return null;
    } finally {
      _downloading = false;
      notifyListeners();
    }
  }

  void clearLedger() {
    _ledger = null;
    _hasSearched = false;
    _loading = false;
    _downloading = false;
    notifyListeners();
  }
}