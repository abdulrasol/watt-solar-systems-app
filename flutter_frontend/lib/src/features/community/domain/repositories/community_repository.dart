import 'dart:io';

import 'package:watt/src/core/models/response.dart';
import 'package:watt/src/features/community/domain/entities/comment_model.dart';
import 'package:watt/src/features/community/domain/entities/post_model.dart';

abstract class CommunityRepository {
  Future<PaginatedItemsResponse<PostModel>> getPosts({int page = 1, int pageSize = 10, String? postType});
  
  Future<PostModel> getPost(int postId);
  
  Future<PostModel> createPost({
    String? content,
    String? postType,
    int? companyId,
    int? systemId,
    File? image,
  });
  
  Future<PostModel> updatePost({
    required int postId,
    String? content,
    String? postType,
  });
  
  Future<void> deletePost(int postId);

  Future<PaginatedItemsResponse<CommentModel>> getComments({
    required int postId,
    int page = 1,
    int pageSize = 10,
  });
  
  Future<CommentModel> createComment({
    required int postId,
    required String content,
  });
  
  Future<CommentModel> updateComment({
    required int commentId,
    required String content,
  });
  
  Future<void> deleteComment(int commentId);
}
