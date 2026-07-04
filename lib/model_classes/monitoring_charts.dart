class AmountGraphModel {
  final ChartData chartData;

  AmountGraphModel({
    required this.chartData,
  });

  factory AmountGraphModel.fromJson(
      Map<String, dynamic> json,
      String key,
      ) {
    return AmountGraphModel(
      chartData: ChartData.fromJson(
        json[key] ?? {},
      ),
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
      labels: List<String>.from(json["labels"] ?? []),
      datasets: (json["datasets"] as List<dynamic>? ?? [])
          .map((e) => ChartDataset.fromJson(e))
          .toList(),
    );
  }
}

class ChartDataset {
  final String label;
  final List<double> data;
  final String unit;

  ChartDataset({
    required this.label,
    required this.data,
    required this.unit,
  });

  factory ChartDataset.fromJson(Map<String, dynamic> json) {
    return ChartDataset(
      label: json["label"] ?? "",
      data: (json["data"] as List<dynamic>? ?? [])
          .map((e) => (e as num).toDouble())
          .toList(),
      unit: json["unit"] ?? "",
    );
  }
}