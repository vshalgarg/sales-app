class BillItem {
  final int? pieces;
  final double? grossAmount;
  final double? discountPercent;
  final double? discountAmount;
  final double? addOnAmount;
  final double? ecrAmount;
  final double? gstPercent;
  final double? gstAmount;
  final double? taxableValue;
  final double? totalAmount;

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
      grossAmount: (json['grossAmount'] as num?)?.toDouble(),
      discountPercent: (json['discountPercent'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      addOnAmount: (json['addOnAmount'] as num?)?.toDouble(),
      ecrAmount: (json['ecrAmount'] as num?)?.toDouble(),
      gstPercent: (json['gstPercent'] as num?)?.toDouble(),
      gstAmount: (json['gstAmount'] as num?)?.toDouble(),
      taxableValue: (json['taxableValue'] as num?)?.toDouble(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
    );
  }
}