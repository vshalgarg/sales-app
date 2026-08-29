import '../../model_classes/configuration_model.dart';
import '../../network/api_service.dart';
import '../../network/response_result.dart';

class ConfigurationService {
  final ApiService _api;

  ConfigurationService(this._api);

  static const String _configuration = "/admin/configurations";

  // GET CONFIGURATION
  Future<ResponseResult<List<ConfigurationModel>>> getConfiguration() async {
    final response = await _api.get(
      path: _configuration,
      showLoader: true,
    );

    if (response.isFailure) {
      return ResponseResult.error(
        errorMessage: response.errorMessage ?? "Failed to fetch configuration",
        dioErrorType: response.dioErrorType,
        statusCode: response.statusCode,
      );
    }

    try {
      final List list = response.data["data"] ?? [];

      final configurations = list
          .map(
            (e) => ConfigurationModel.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList();

      return ResponseResult.success(
        configurations,
        response.statusCode,
      );
    } catch (e) {
      return ResponseResult.error(
        errorMessage: "Failed to parse configuration: $e",
        statusCode: response.statusCode,
      );
    }
  }

  // UPDATE CONFIGURATION
  Future<ResponseResult<dynamic>> updateConfiguration({
    required int id,
    required bool value,
  }) async {
    return await _api.patch(
      path: "$_configuration/$id",
      data: {
        "value": value,
      },
      showLoader: true,
    );
  }
}