import 'package:flutter/material.dart';

import '../../model_classes/graph_response_model.dart';
import '../../model_classes/monitoring_charts.dart';
import '../../model_classes/staff_analytics_model.dart';
import '../../services/monitoring_services/graph_services.dart';

class GraphProvider extends ChangeNotifier {

  final GraphResponseServices _service = GraphResponseServices();

  GraphResponse? graphResponse;
  bool isLoading = false;
  String? error;
  StaffAnalyticsModel?analytics;
  AmountGraphModel?response;
  AmountGraphModel? customerResponse;

  Future<void> getMonthlyAnalytics({
    required Map<String, dynamic> body,
  }) async {

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      graphResponse = await _service.graphResponse(body: body);
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
  Future<void> getStaffAnalytics({
    required Map<String, dynamic> body,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      analytics = await _service.graphStaffResponse(body: body);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Future<void> getSupplierAmount({
    required Map<String, dynamic> body,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      response = await _service.graphSupplierAmountResponse(
        body: body,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  } Future<void> getCustomerAmount({
    required Map<String, dynamic> body,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      customerResponse = await _service.graphCustomerAmountResponse(
        body: body,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}