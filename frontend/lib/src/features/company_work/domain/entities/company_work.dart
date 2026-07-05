import 'package:solar_hub/src/core/utils/date_parser.dart';
class CompanyWorkImage {
  const CompanyWorkImage({
    required this.id,
    required this.imageUrl,
    this.createdAt,
  });

  final int id;
  final String imageUrl;
  final DateTime? createdAt;

  factory CompanyWorkImage.fromJson(Map<String, dynamic> json) {
    return CompanyWorkImage(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      imageUrl: json['image_url']?.toString() ?? '',
      createdAt: safeParseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class CompanyWork {
  const CompanyWork({
    required this.id,
    required this.title,
    this.body,
    this.createdAt,
    this.updatedAt,
    this.images = const [],
  });

  final int id;
  final String title;
  final String? body;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<CompanyWorkImage> images;

  String? get coverImageUrl => images.isEmpty ? null : images.first.imageUrl;

  factory CompanyWork.fromJson(Map<String, dynamic> json) {
    return CompanyWork(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString(),
      createdAt: safeParseDate(json['created_at']),
      updatedAt: safeParseDate(json['updated_at']),
      images: (json['images'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                CompanyWorkImage.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'images': images.map((image) => image.toJson()).toList(),
    };
  }

  CompanyWork copyWith({
    int? id,
    String? title,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CompanyWorkImage>? images,
  }) {
    return CompanyWork(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
    );
  }
}
