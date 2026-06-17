import 'package:flutter/material.dart';

class BillItemProvider extends ChangeNotifier {

  double taxableValue = 0;
  double gstValue = 0;
  double billValue = 0;
  double discountAmount = 0;
  double gstAmount = 0;

  void calculate({
    required String grossAmount,
    required String discountPercentage,
    required String addAmount,
    required String ecrAmount,
    required String gstPercentage,
  }) {

    double gross = double.tryParse(grossAmount) ?? 0;
    double discount = double.tryParse(discountPercentage) ?? 0;
    double addOn = double.tryParse(addAmount) ?? 0;
    double ecr = double.tryParse(ecrAmount) ?? 0;
    double gst = double.tryParse(gstPercentage) ?? 0;

    discountAmount = gross * discount / 100;
    gstAmount = taxableValue * gst / 100;

    taxableValue = gross - discountAmount + addOn + ecr;

    gstValue = taxableValue * gst / 100;

    billValue = taxableValue + gstValue;

    notifyListeners();
  }
  void reset() {
    taxableValue = 0;
    gstValue = 0;
    billValue = 0;
    discountAmount = 0;
    gstAmount = 0;

    notifyListeners();
  }
}