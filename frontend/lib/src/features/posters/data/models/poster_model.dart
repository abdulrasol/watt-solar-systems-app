import 'package:solar_hub/src/core/utils/date_parser.dart';
import 'package:solar_hub/src/features/posters/domain/entities/poster_entity.dart';

class PosterModel {
  final int id;
  final int companyId;
  final String? companyName;
  final String? imageUrl;
  final String? text;
  final String actionType;
  final int? actionId;
  final String status;
  final bool isActive;
  final int? durationDays;
  final DateTime? approvedAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PosterModel({
    required this.id,
    required this.companyId,
    this.companyName,
    this.imageUrl,
    this.text,
    required this.actionType,
    this.actionId,
    required this.status,
    required this.isActive,
    this.durationDays,
    this.approvedAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory PosterModel.fromJson(Map<String, dynamic> json) {
    return PosterModel(
      id: _parseInt(json['id']) ?? 0,
      companyId: _parseInt(json['company_id']) ?? 0,
      companyName: json['company_name']?.toString(),
      imageUrl: json['image_url']?.toString(),
      text: json['text']?.toString(),
      actionType: json['action_type']?.toString() ?? '',
      actionId: _parseInt(json['action_id']),
      status: json['status']?.toString() ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 'true',
      durationDays: _parseInt(json['duration_days']),
      approvedAt: safeParseDate(json['approved_at']),
      expiresAt: safeParseDate(json['expires_at']),
      createdAt: safeParseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: safeParseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  PosterEntity toEntity() {
    return PosterEntity(
      id: id,
      companyId: companyId,
      companyName: companyName,
      imageUrl: imageUrl,
      text: text,
      actionType: actionType,
      actionId: actionId,
      status: status,
      isActive: isActive,
      durationDays: durationDays,
      approvedAt: approvedAt,
      expiresAt: expiresAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
