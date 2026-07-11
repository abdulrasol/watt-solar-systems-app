import 'package:watt/src/features/community/domain/entities/post_model.dart';

class CommentModel {
  final int id;
  final int postId;
  final String content;
  final DateTime createdAt;
  final CommunityAuthorInfo authorInfo;

  CommentModel({
    required this.id,
    required this.postId,
    required this.content,
    required this.createdAt,
    required this.authorInfo,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as int,
      postId: json['post_id'] as int,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      authorInfo: CommunityAuthorInfo.fromJson(json['author_info'] as Map<String, dynamic>),
    );
  }
}
