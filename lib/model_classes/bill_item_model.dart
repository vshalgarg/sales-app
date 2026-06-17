class BillItem {
  final int? pieces;
  final double? grossAmount;

  final double? discountPercent;
  final double ?discountAmount;

  final double ?addOnAmount;
  final double ?ecrAmount;

  final double ?gstPercent;
  final double ?gstAmount;

  final double ?taxableValue;
  final double ?totalAmount;

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
}