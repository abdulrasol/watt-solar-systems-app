import 'package:solar_hub/features/profile/models/profile_model.dart';

class CommunityPostModel {
  final String id;
  final String? authorId;
  final String? companyId;
  final String? content;
  final List<String> imageUrls;
  final String postType;
  final int likesCount;
  final String? systemId;
  final DateTime createdAt;

  // Joined Data
  final ProfileModel? author;
  final String? companyName;
  final String? companyLogo;
  final String? linkedSystemName;
  final double? linkedSystemCapacity;
  final bool isLikedByMe;

  CommunityPostModel({
    required this.id,
    this.authorId,
    this.companyId,
    this.content,
    this.imageUrls = const [],
    this.postType = 'general',
    this.likesCount = 0,
    this.systemId,
    required this.createdAt,
    this.author,
    this.companyName,
    this.companyLogo,
    this.linkedSystemName,
    this.linkedSystemCapacity,
    this.isLikedByMe = false,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    // Parse author if joined
    ProfileModel? author;
    if (json['author'] != null) {
      author = ProfileModel.fromJson(json['author']);
    } else if (json['profiles'] != null) {
      // Sometimes join returns table name
      author = ProfileModel.fromJson(json['profiles']);
    }

    // Parse company info from joined 'companies' table
    String? cName;
    String? cLogo;
    if (json['companies'] != null) {
      cName = json['companies']['name'];
      cLogo = json['companies']['logo_url'];
    }

    // Parse system info
    String? sName;
    double? sCap;
    if (json['systems'] != null) {
      sName = json['systems']['system_name'];
      sCap = (json['systems']['capacity_kw'] as num?)?.toDouble();
    }

    // Check if liked by current user (requires a separate check or join,
    // usually handled by fetching 'likes' table with filter or client side check if list loaded)
    // For now assuming passed in or false
    bool liked = false;
    if (json['is_liked'] != null) {
      liked = json['is_liked'];
    }

    return CommunityPostModel(
      id: json['id'],
      authorId: json['author_id'],
      companyId: json['company_id'],
      content: json['content'],
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      postType: json['post_type'] ?? 'general',
      likesCount: json['likes_count'] ?? 0,
      systemId: json['system_id'],
      createdAt: DateTime.parse(json['created_at']),
      author: author,
      companyName: cName,
      companyLogo: cLogo,
      linkedSystemName: sName,
      linkedSystemCapacity: sCap,
      isLikedByMe: liked,
    );
  }

  bool get isCompanyPost => companyId != null;

  String? get userName => isCompanyPost ? companyName : author?.fullName;
}
