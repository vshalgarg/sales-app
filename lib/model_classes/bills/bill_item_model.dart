class BillItem {
  final num? pieces;
  final num? grossAmount;
  final num? discountPercent;
  final num? discountAmount;
  final num? addOnAmount;
  final num? ecrAmount;
  final num? gstPercent;
  final num? gstAmount;
  final num? taxableValue;
  final num? totalAmount;

  BillItem({
    this.pieces,
    this.grossAmount,
    this.discountPercent,
    this.discountAmount,
    this.addOnAmount,
    this.ecrAmount,
    this.gstPercent,
    this.gstAmount,
    this.taxableValue,
    this.totalAmount,
  });

  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      pieces: json['pieces'],
      grossAmount: json['grossAmount'],
      discountPercent: json['discountPercent'],
      discountAmount: json['discountAmount'],
      addOnAmount: json['addOnAmount'],
      ecrAmount: json['ecrAmount'],
      gstPercent: json['gstPercent'],
      gstAmount: json['gstAmount'],
      taxableValue: json['taxableValue'],
      totalAmount: json['totalAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pieces': pieces,
      'grossAmount': grossAmount,
      'discountPercent': discountPercent,
      'discountAmount': discountAmount,
      'addOnAmount': addOnAmount,
      'ecrAmount': ecrAmount,
      'gstPercent': gstPercent,
      'gstAmount': gstAmount,
      'taxableValue': taxableValue,
      'totalAmount': totalAmount,
    };
  }
}