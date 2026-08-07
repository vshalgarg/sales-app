// class DeletePurchaseResponse {
//   final int id;
//   final String message;
//
//   DeletePurchaseResponse({
//     required this.id,
//     required this.message,
//   });
//
//   factory DeletePurchaseResponse.fromJson(Map<String, dynamic> json) {
//     return DeletePurchaseResponse(
//       id: json["id"] ?? 0,
//       message: json["message"] ?? "",
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       "id": id,
//       "message": message,
//     };
//   }
// }