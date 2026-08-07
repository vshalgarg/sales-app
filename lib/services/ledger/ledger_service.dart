import 'dart:typed_data';

import '../../../model_classes/common/api_response.dart';
import '../../../network/api_service.dart';
import '../../../network/response_result.dart';
import '../../model_classes/get_ledger_details.dart';

class LedgerService {
  final ApiService _api;

  LedgerService(this._api);

  static const String _ledger = "/ledger";

  // GET LEDGER

  Future<ResponseResult<ApiResponse>> getLedger({
    required num supplierId,
    required num customerId,
    required String viewType,
  }) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: _ledger,
      queryParameters: {
        "supplierId": supplierId,
        "customerId": customerId,
        "viewType": viewType,
      },
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to fetch ledger",
        statusCode: result.statusCode,
      );
    }

    final response = ApiResponse.fromJson(result.data!);

    return ResponseResult.success(
      ApiResponse(
        success: response.success,
        message: response.message,
        data: response.data != null
            ? LedgerData.fromJson(
          response.data as Map<String, dynamic>,
        )
            : null,
      ),
      result.statusCode,
    );
  }

  // DOWNLOAD LEDGER

  Future<ResponseResult<Uint8List>> downloadLedger({
    required num supplierId,
    required num customerId,
    required String viewType,
  }) {
    return _api.downloadBytes(
      path: "$_ledger/download",
      queryParameters: {
        "supplierId": supplierId,
        "customerId": customerId,
        "viewType": viewType,
      },
    );
  }
}
