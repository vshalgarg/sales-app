class GraphResponse {
  final bool success;
  final String message;
  final GraphData data;

  GraphResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory GraphResponse.fromJson(Map<String, dynamic> json) {
    return GraphResponse(
      success: json["success"],
      message: json["message"],
      data: GraphData.fromJson(json["data"]),
    );
  }
}

class GraphData {
  final List<String> labels;
  final List<GraphDataset> datasets;

  GraphData({
    required this.labels,
    required this.datasets,
  });

  factory GraphData.fromJson(Map<String, dynamic> json) {
    return GraphData(
      labels: List<String>.from(json["labels"]),
      datasets: (json["datasets"] as List)
          .map((e) => GraphDataset.fromJson(e))
          .toList(),
    );
  }
}

class GraphDataset {
  final String label;
  final String unit;
  final List<double?> data;

  GraphDataset({
    required this.label,
    required this.unit,
    required this.data,
  });

  factory GraphDataset.fromJson(Map<String, dynamic> json) {
    return GraphDataset(
      label: json["label"],
      unit: json["unit"],
      data: (json["data"] as List)
          .map((e) => e == null ? null : (e as num).toDouble())
          .toList(),
    );
  }
}