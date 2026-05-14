import 'package:flutter/cupertino.dart';
import 'package:hisabio/services/delete_supplier_api.dart';

class DeleteSupplierProvider extends ChangeNotifier {

  final DeleteSupplierApi api = DeleteSupplierApi();

  bool isLoading = false;

  String message = "";

  Future<void> deleteSupplier(String code) async {

    isLoading = true;
    notifyListeners();

    try {

      final response = await api.deleteSupplier({
        "code": code,
      });

      message = response.message ?? "";

    } catch (e) {

      message = e.toString();

    } finally {

      isLoading = false;
      notifyListeners();

    }
  }
}