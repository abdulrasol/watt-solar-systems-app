class CommunityAuthorInfo {
  final String id;
  final String name;
  final String type;
  final String? image;
  final String? role;
  final String? phone;

  CommunityAuthorInfo({
    required this.id,
    required this.name,
    required this.type,
    this.image,
    this.role,
    this.phone,
  });

  factory CommunityAuthorInfo.fromJson(Map<String, dynamic> json) {
    return CommunityAuthorInfo(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Unknown',
      type: json['type'] as String? ?? 'user',
      image: json['image'] as String?,
      role: json['role'] as String?,
      phone: json['phone'] as String?,
    );
  }
}

class PostModel {
  final int id;
  final String? content;
  final String? imageUrl;
  final String postType;
  final int likesCount;
  final DateTime createdAt;
  final CommunityAuthorInfo authorInfo;

  PostModel({
    required this.id,
    this.content,
    this.imageUrl,
    required this.postType,
    this.likesCount = 0,
    required this.createdAt,
    required this.authorInfo,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as int,
      content: json['content'] as String?,
      imageUrl: json['image_url'] as String?,
      postType: json['post_type'] as String? ?? 'general',
      likesCount: json['likes_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorInfo: CommunityAuthorInfo.fromJson(json['author_info'] as Map<String, dynamic>),
    );
  }
}
