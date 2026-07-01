import 'package:flutter/material.dart';

import '../../model_classes/graph_response_model.dart';
import '../../services/monitoring_services/graph_services.dart';

class GraphProvider extends ChangeNotifier {

  final GraphResponseServices _service = GraphResponseServices();

  GraphResponse? graphResponse;
  bool isLoading = false;
  String? error;

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
}