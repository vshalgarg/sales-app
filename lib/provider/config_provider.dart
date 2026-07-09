import 'package:flutter/cupertino.dart';

import '../services/configuration_services.dart';

class ConfigProvider extends ChangeNotifier {

  bool retailEnabled = false;

  void setRetailEnabled(bool value){
    retailEnabled = value;
    notifyListeners();
  }

  Future<void> fetchConfiguration() async {
    final response = await ConfigurationService().getConfiguration();

    retailEnabled = response
        .firstWhere((e) => e.key == "RETAIL_FEATURE")
        .value
        .toLowerCase() == "true";

    notifyListeners();
  }

  Future<void> saveConfiguration(bool value) async {
    await ConfigurationService().updateConfiguration(value);

    await fetchConfiguration();
  }
}