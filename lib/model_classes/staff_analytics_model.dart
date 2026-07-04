class StaffAnalyticsModel {
  final ChartData supplierVsStaff;
  final ChartData customerVsStaff;
  final ChartData supplierAndCustomerVsStaff;

  StaffAnalyticsModel({
    required this.supplierVsStaff,
    required this.customerVsStaff,
    required this.supplierAndCustomerVsStaff,
  });

  factory StaffAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return StaffAnalyticsModel(
      supplierVsStaff: ChartData.fromJson(json['supplierVsStaff'] ?? {}),
      customerVsStaff: ChartData.fromJson(json['customerVsStaff'] ?? {}),
      supplierAndCustomerVsStaff:
      ChartData.fromJson(json['supplierAndCustomerVsStaff'] ?? {}),
    );
  }
}

class ChartData {
  final List<String> labels;
  final List<ChartDataset> datasets;

  ChartData({
    required this.labels,
    required this.datasets,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      labels: List<String>.from(json['labels'] ?? []),
      datasets: (json['datasets'] as List<dynamic>? ?? [])
          .map((e) => ChartDataset.fromJson(e))
          .toList(),
    );
  }
}

class ChartDataset {
  final String label;
  final List<int> data;
  final String unit;

  ChartDataset({
    required this.label,
    required this.data,
    required this.unit,
  });

  factory ChartDataset.fromJson(Map<String, dynamic> json) {
    return ChartDataset(
      label: json['label'] ?? '',
      data: List<int>.from(json['data'] ?? []),
      unit: json['unit'] ?? '',
    );
  }
}