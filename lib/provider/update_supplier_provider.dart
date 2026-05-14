import 'package:flutter/material.dart';
import 'package:hisabio/model_classes/update_supplier_model.dart';
import 'package:hisabio/services/update_supplier.dart';

class UpdateSupplierProvider extends ChangeNotifier {

  final UpdateSupplierApi api = UpdateSupplierApi();

  bool isLoading = false;
  String? error;
  UpdateSupplierModel? response;

  Future<void> updateSupplier({
    required int id,
    required Map<String, dynamic> body,
  }) async {

    isLoading = true;
    error = null;
    notifyListeners();

    try {

      response = await api.updateSupplier(
        id: id,
        body: body,
      );

    } catch (e) {

      error = e.toString();

    }

    isLoading = false;
    notifyListeners();
  }
}