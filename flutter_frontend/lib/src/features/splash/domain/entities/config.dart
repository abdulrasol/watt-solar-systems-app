class Config {
  final String key;
  final bool value;
  final String? description;

  Config({required this.key, required this.value, this.description});

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(key: json['key'], value: json['value'], description: json['description']);
  }

  Map<String, dynamic> toJson() {
    return {'key': key, 'value': value, 'description': description};
  }
}
