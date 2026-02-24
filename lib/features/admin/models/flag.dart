class Flag {
  final String key;
  final bool value;
  final String? description;

  Flag({required this.key, required this.value, this.description});

  factory Flag.fromJson(Map<String, dynamic> json) =>
      Flag(key: json['key'] as String, value: json['value'] as bool, description: json['description'] as String?);

  Map<String, dynamic> toJson() => {'key': key, 'value': value, 'description': description};

  Flag copyWith({String? key, bool? value, String? description}) {
    return Flag(key: key ?? this.key, value: value ?? this.value, description: description ?? this.description);
  }
}
