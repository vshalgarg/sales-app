import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../../../model_classes/Transport/transport.dart';
import '../../../model_classes/common/api_response.dart';
import '../../../model_classes/entries/add_newsupplier.dart';
import '../../../model_classes/entries/entries_customer_model.dart';
import '../../../model_classes/entries/entries_supplier.dart';
import '../../../model_classes/entries/get_staff_entry.dart';
import '../../../network/api_service.dart';
import '../../../network/response_result.dart';

class EntriesService {
  final ApiService _api;

  EntriesService(this._api);

  static const String _suppliers = "/suppliers";
  static const String _customers = "/customers";
  static const String _transports = "/transports";
  static const String _staffs = "/staffs";
  static const String _credit = "/credit";
  static const String _bill = "/bill";
  static const String _purchase = "/purchase";
  static const String _retail = "/retail";

  // FETCH SUPPLIERS

  Future<ResponseResult<List<EntriesModel>>> fetchSuppliers() async {
    final sw = Stopwatch()..start();
    final result = await _api.get<List<dynamic>>(path: "$_suppliers/get/all");
    print("Supplier API: ${sw.elapsedMilliseconds} ms");
    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to fetch suppliers",
        statusCode: result.statusCode,
      );
    }

    final suppliers = (result.data ?? [])
        .map((e) => EntriesModel.fromJson(e))
        .toList();

    return ResponseResult.success(suppliers, result.statusCode);
  }

  // FETCH CUSTOMERS

  Future<ResponseResult<List<EntriesCustomerModel>>> fetchCustomers() async {
    final sw = Stopwatch()..start();
    final result = await _api.get<List<dynamic>>(path: "$_customers/get/all");
    print("Customer API: ${sw.elapsedMilliseconds} ms");
    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to fetch customers",
        statusCode: result.statusCode,
      );
    }

    final customers = (result.data ?? [])
        .map((e) => EntriesCustomerModel.fromJson(e))
        .toList();

    return ResponseResult.success(customers, result.statusCode);
  }

  // FETCH TRANSPORTS

  Future<ResponseResult<List<Transport>>> fetchTransports() async {
    final result = await _api.get<List<dynamic>>(path: "$_transports/getAll");

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to fetch transports",
        statusCode: result.statusCode,
      );
    }

    final transports = (result.data ?? [])
        .map((e) => Transport.fromJson(e))
        .toList();

    return ResponseResult.success(transports, result.statusCode);
  }

  // FETCH STAFF

  Future<ResponseResult<List<GetStaffEntry>>> fetchStaff() async {
    final result = await _api.get<List<dynamic>>(path: "$_staffs/get/all");

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to fetch staff",
        statusCode: result.statusCode,
      );
    }

    final staff = (result.data ?? [])
        .map((e) => GetStaffEntry.fromJson(e))
        .toList();

    return ResponseResult.success(staff, result.statusCode);
  }

  // ADD SUPPLIER

  Future<ResponseResult<ApiResponse>> addSupplier({
    required Map<String, dynamic> body,
  }) async {
    final result = await _api.post<Map<String, dynamic>>(
      path: "/retail-suppliers",
      data: body,
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to add supplier",
        statusCode: result.statusCode,
      );
    }

    final response = ApiResponse.fromJson(result.data!);

    if (!response.success) {
      return ResponseResult.error(
        errorMessage: response.message,
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(response, result.statusCode);
  }

  // ADD CREDIT ENTRY

  Future<ResponseResult<AddNewSupplier>> addCreditEntry({
    required Map<String, dynamic> body,
  }) async {
    final result = await _api.post<Map<String, dynamic>>(
      path: "$_credit/entry/add",
      data: body,
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to add credit entry",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      AddNewSupplier.fromJson(result.data!),
      result.statusCode,
    );
  }

  // ADD RETAIL ENTRY

  Future<ResponseResult<ApiResponse>> addRetailEntry({
    required Map<String, dynamic> body,
  }) async {
    final result = await _api.post<Map<String, dynamic>>(
      path: "$_retail/create",
      data: body,
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to add retail entry",
        statusCode: result.statusCode,
      );
    }

    final response = ApiResponse.fromJson(result.data!);

    if (!response.success) {
      return ResponseResult.error(
        errorMessage: response.message,
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(response, result.statusCode);
  }

  // ADD BILL

  Future<ResponseResult<ApiResponse>> addBill({
    required Map<String, dynamic> payload,
    List<File> images = const [],
  }) async {
    final formData = FormData();

    formData.files.add(
      MapEntry(
        "payload",
        MultipartFile.fromString(
          jsonEncode(payload),
          filename: "payload.json",
          contentType: DioMediaType("application", "json"),
        ),
      ),
    );

    for (final image in images) {
      formData.files.add(
        MapEntry(
          "images",
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        ),
      );
    }

    print("=========== BILL PAYLOAD ===========");
    print(jsonEncode(payload));

    final result = await _api.post<Map<String, dynamic>>(
      path: "$_bill/entry/add",
      data: formData,
    );

    print(result.data);

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to add bill",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      ApiResponse.fromJson(result.data!),
      result.statusCode,
    );
  }

  // UPDATE BILL

  Future<ResponseResult<ApiResponse>> updateBill({
    required int id,
    required Map<String, dynamic> payload,
    List<File> images = const [],
  }) async {
    final formData = FormData();

    formData.files.add(
      MapEntry(
        "data",
        MultipartFile.fromBytes(
          utf8.encode(jsonEncode(payload)),
          filename: "blob",
          contentType: DioMediaType("application", "json"),
        ),
      ),
    );

    for (final image in images) {
      formData.files.add(
        MapEntry(
          "images",
          await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          ),
        ),
      );
    }

    print("========== UPDATE BILL ==========");
    print(jsonEncode(payload));

    final result = await _api.patch<Map<String, dynamic>>(
      path: "$_bill/entry/update/$id",
      data: formData,
    );

    print("Status : ${result.statusCode}");
    print("Response : ${result.data}");
    print("Error : ${result.errorMessage}");

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to update bill",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      ApiResponse.fromJson(result.data!),
      result.statusCode,
    );
  }

  // ADD PURCHASE

  Future<ResponseResult<ApiResponse>> addPurchase({
    required Map<String, dynamic> payload,
    required List<List<PlatformFile>> uploadedFiles,
    required List<EntriesModel?> selectedSuppliers,
  }) async {
    final formData = FormData();

    formData.fields.add(MapEntry("payload", jsonEncode(payload)));

    for (int i = 0; i < uploadedFiles.length; i++) {
      final supplierId = selectedSuppliers[i]?.id;

      if (supplierId == null) continue;

      for (final file in uploadedFiles[i]) {
        if (file.path == null) continue;

        formData.files.add(
          MapEntry(
            "supplier_${supplierId}_images",
            await MultipartFile.fromFile(file.path!, filename: file.name),
          ),
        );
      }
    }

    final result = await _api.post<Map<String, dynamic>>(
      path: "$_purchase/entry/add",
      data: formData,
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to add purchase",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      ApiResponse.fromJson(result.data!),
      result.statusCode,
    );
  }

  // GET CREDIT DETAILS

  Future<ResponseResult<ApiResponse>> getCreditDetailsById(int id) async {
    final result = await _api.get<Map<String, dynamic>>(
      path: "$_credit/details/$id",
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to fetch credit details",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      ApiResponse.fromJson(result.data!),
      result.statusCode,
    );
  }

  // UPDATE CREDIT DETAILS

  Future<ResponseResult<AddNewSupplier>> updateCreditDetails({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    final result = await _api.patch<Map<String, dynamic>>(
      path: "$_credit/entry/update/$id",
      data: body,
    );

    if (result.isFailure) {
      return ResponseResult.error(
        errorMessage: result.errorMessage ?? "Failed to update credit details",
        statusCode: result.statusCode,
      );
    }

    return ResponseResult.success(
      AddNewSupplier.fromJson(result.data!),
      result.statusCode,
    );
  }
}
