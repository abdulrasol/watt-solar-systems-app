import 'dart:io';

import 'package:watt/src/core/models/response.dart';
import 'package:watt/src/features/community/data/data_sources/community_remote_data_source.dart';
import 'package:watt/src/features/community/domain/entities/comment_model.dart';
import 'package:watt/src/features/community/domain/entities/post_model.dart';
import 'package:watt/src/features/community/domain/repositories/community_repository.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource _remoteDataSource;

  CommunityRepositoryImpl(this._remoteDataSource);

  @override
  Future<PaginatedItemsResponse<PostModel>> getPosts({int page = 1, int pageSize = 10, String? postType}) {
    return _remoteDataSource.getPosts(page: page, pageSize: pageSize, postType: postType);
  }

  @override
  Future<PostModel> getPost(int postId) {
    return _remoteDataSource.getPost(postId);
  }

  @override
  Future<PostModel> createPost({
    String? content,
    String? postType,
    int? companyId,
    int? systemId,
    File? image,
  }) {
    return _remoteDataSource.createPost(
      content: content,
      postType: postType,
      companyId: companyId,
      systemId: systemId,
      image: image,
    );
  }

  @override
  Future<PostModel> updatePost({
    required int postId,
    String? content,
    String? postType,
  }) {
    return _remoteDataSource.updatePost(
      postId: postId,
      content: content,
      postType: postType,
    );
  }

  @override
  Future<void> deletePost(int postId) {
    return _remoteDataSource.deletePost(postId);
  }

  @override
  Future<PaginatedItemsResponse<CommentModel>> getComments({
    required int postId,
    int page = 1,
    int pageSize = 10,
  }) {
    return _remoteDataSource.getComments(postId: postId, page: page, pageSize: pageSize);
  }

  @override
  Future<CommentModel> createComment({
    required int postId,
    required String content,
  }) {
    return _remoteDataSource.createComment(postId: postId, content: content);
  }

  @override
  Future<CommentModel> updateComment({
    required int commentId,
    required String content,
  }) {
    return _remoteDataSource.updateComment(commentId: commentId, content: content);
  }

  @override
  Future<void> deleteComment(int commentId) {
    return _remoteDataSource.deleteComment(commentId);
  }
}
