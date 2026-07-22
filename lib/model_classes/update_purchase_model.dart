class UpdatePurchaseResponse {
  final String message;

  UpdatePurchaseResponse({
    required this.message,
  });

  factory UpdatePurchaseResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    return UpdatePurchaseResponse(
      message: json["message"] ?? "",
    );
  }
}