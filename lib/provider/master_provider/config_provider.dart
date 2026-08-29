import 'package:flutter/cupertino.dart';

import '../../services/config/configuration_services.dart';

class ConfigProvider extends ChangeNotifier {
  final ConfigurationService _configurationService;

  ConfigProvider(this._configurationService);

  bool retailEnabled = false;

  int? _retailConfigurationId;

  void setRetailEnabled(bool value) {
    retailEnabled = value;
    notifyListeners();
  }

  Future<void> fetchConfiguration() async {
    final response =
    await _configurationService.getConfiguration();

    if (response.isFailure || response.data == null) {
      return;
    }

    final configurations = response.data!;

    final retailConfig = configurations.firstWhere(
          (e) => e.key == "RETAIL_FEATURE",
    );

    _retailConfigurationId = retailConfig.id;

    retailEnabled =
        retailConfig.value.toLowerCase() == "true";

    notifyListeners();
  }

  Future<void> saveConfiguration(bool value) async {
    if (_retailConfigurationId == null) {
      throw Exception("Retail configuration not found");
    }

    final response =
    await _configurationService.updateConfiguration(
      id: _retailConfigurationId!,
      value: value,
    );

    if (response.isFailure) {
      throw Exception(
        response.errorMessage ?? "Failed to update configuration",
      );
    }

    retailEnabled = value;
    notifyListeners();
  }
}