import '../network/api_service.dart';
import '../network/response_result.dart';

class AddSupplierApi {
  final ApiService _api;
  AddSupplierApi(this._api);
  Future<String> addSupplier(Map<String, dynamic> body) async {
    final ResponseResult<dynamic> result = await _api.post(
      path: '/csm/api/v1/retail-suppliers',
      data: body,
    );
    if (result.isFailure) {
      throw Exception(result.errorMessage ?? "Failed to add supplier");
    }

    final data = result.data;
    if (data["success"] == true) {
      return data["message"];
    }

    throw Exception(data["message"] ?? "Failed to add supplier");
  }
}
