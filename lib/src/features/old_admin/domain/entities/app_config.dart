import 'package:equatable/equatable.dart';

class AppConfig extends Equatable {
  final String key;
  final bool value;
  final String? description;
  final DateTime? updatedAt;

  const AppConfig({required this.key, required this.value, this.description, this.updatedAt});

  AppConfig copyWith({String? key, bool? value, String? description, DateTime? updatedAt}) {
    return AppConfig(key: key ?? this.key, value: value ?? this.value, description: description ?? this.description, updatedAt: updatedAt ?? this.updatedAt);
  }

  Map<String, dynamic> toJson() {
    return {'key': key, 'value': value, 'description': description, 'updated_at': updatedAt?.toIso8601String()};
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      key: json['key'] ?? '',
      value: json['value'] ?? false,
      description: json['description'],
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  @override
  List<Object?> get props => [key, value, description, updatedAt];
}
