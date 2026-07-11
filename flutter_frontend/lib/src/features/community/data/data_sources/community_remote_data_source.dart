import 'dart:io';

import 'package:dio/dio.dart';
import 'package:watt/src/core/models/response.dart';
import 'package:watt/src/core/services/dio.dart';
import 'package:watt/src/features/community/domain/entities/comment_model.dart';
import 'package:watt/src/features/community/domain/entities/post_model.dart';
import 'package:watt/src/utils/app_urls.dart';

class CommunityRemoteDataSource {
  final DioService _dioService;

  CommunityRemoteDataSource(this._dioService);

  Future<PaginatedItemsResponse<PostModel>> getPosts({int page = 1, int pageSize = 10, String? postType}) async {
    final Map<String, dynamic> query = {'page': page, 'page_size': pageSize};
    if (postType != null) {
      query['post_type'] = postType;
    }
    final rawMap = await _dioService.getRawMap(AppUrls.posts, queryParameters: query);
    return PaginatedItemsResponse<PostModel>.fromJson(rawMap, (itemJson) => PostModel.fromJson(itemJson));
  }

  Future<PostModel> getPost(int postId) async {
    final rawMap = await _dioService.getRawMap(AppUrls.postById(postId));
    return PostModel.fromJson(rawMap['body']);
  }

  Future<PostModel> createPost({String? content, String? postType, int? companyId, int? systemId, File? image}) async {
    final formData = FormData.fromMap({
      'content': ?content,
      'post_type': ?postType,
      'company_id': ?companyId,
      'system_id': ?systemId,
      if (image != null) 'image': await MultipartFile.fromFile(image.path),
    });

    final response = await _dioService.multipartRequest(AppUrls.posts, file: formData);
    return PostModel.fromJson(response.body);
  }

  Future<PostModel> updatePost({required int postId, String? content, String? postType}) async {
    final data = <String, dynamic>{};
    if (content != null) data['content'] = content;
    if (postType != null) data['post_type'] = postType;

    final response = await _dioService.put(AppUrls.postById(postId), data: data);
    return PostModel.fromJson(response.body);
  }

  Future<void> deletePost(int postId) async {
    await _dioService.delete(AppUrls.postById(postId));
  }

  Future<PaginatedItemsResponse<CommentModel>> getComments({required int postId, int page = 1, int pageSize = 10}) async {
    final rawMap = await _dioService.getRawMap(AppUrls.postComments(postId), queryParameters: {'page': page, 'page_size': pageSize});
    return PaginatedItemsResponse<CommentModel>.fromJson(rawMap, (itemJson) => CommentModel.fromJson(itemJson));
  }

  Future<CommentModel> createComment({required int postId, required String content}) async {
    final response = await _dioService.post(AppUrls.postComments(postId), data: {'content': content});
    return CommentModel.fromJson(response.body);
  }

  Future<CommentModel> updateComment({required int commentId, required String content}) async {
    final response = await _dioService.put(AppUrls.commentById(commentId), data: {'content': content});
    return CommentModel.fromJson(response.body);
  }

  Future<void> deleteComment(int commentId) async {
    await _dioService.delete(AppUrls.commentById(commentId));
  }
}
