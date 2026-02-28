class Config {
  final String key;
  final bool value;
  final String? description;
  final DateTime? updatedAt;

  Config({required this.key, required this.value, this.description, this.updatedAt});

  factory Config.fromJson(Map<String, dynamic> json) => Config(
    key: json['key'] as String,
    value: json['value'] as bool,
    description: json['description'] as String?,
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
  );

  Map<String, dynamic> toJson() => {'key': key, 'value': value, 'description': description};

  Config copyWith({String? key, bool? value, String? description}) {
    return Config(key: key ?? this.key, value: value ?? this.value, description: description ?? this.description);
  }
}
