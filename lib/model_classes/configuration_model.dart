class ConfigurationModel {
  final int id;
  final String key;
  final String value;
  final String type;

  ConfigurationModel({
    required this.id,
    required this.key,
    required this.value,
    required this.type,
  });

  factory ConfigurationModel.fromJson(Map<String, dynamic> json) {
    return ConfigurationModel(
      id: json['id'],
      key: json['key'],
      value: json['value'],
      type: json['type'],
    );
  }

  bool get isEnabled => value.toLowerCase() == "true";
}