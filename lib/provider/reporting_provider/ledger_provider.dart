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

  bool _downloading = false;

  LedgerData? get ledger => _ledger;

  bool get downloading => _downloading;

  Future<void> fetchLedger({
    required int supplierId,
    required int customerId,
    required String viewType,
  }) async {
    try {
      final result = await _service.getLedger(
        supplierId: supplierId,
        customerId: customerId,
        viewType: viewType,
      );

      if (result.isSuccess) {
        _ledger = result.data?.data as LedgerData?;
        _hasSearched = true;
      } else {
        _ledger = null;
        _hasSearched = true;

        debugPrint(
          "Ledger API error: ${result.errorMessage}",
        );
      }
    } catch (e, stackTrace) {
      _ledger = null;
      _hasSearched = true;

      debugPrint("Ledger exception: $e");
      debugPrintStack(stackTrace: stackTrace);
    } finally {
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
    _downloading = false;
    notifyListeners();
  }
}