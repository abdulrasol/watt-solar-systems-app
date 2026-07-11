import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watt/src/core/di/get_it.dart';
import 'package:watt/src/core/services/dio.dart';
import 'package:watt/src/features/community/data/data_sources/community_remote_data_source.dart';
import 'package:watt/src/features/community/data/repositories/community_repository_impl.dart';
import 'package:watt/src/features/community/domain/entities/comment_model.dart';
import 'package:watt/src/features/community/domain/entities/post_model.dart';
import 'package:watt/src/features/community/domain/repositories/community_repository.dart';

final communityRemoteDataSourceProvider = Provider<CommunityRemoteDataSource>((ref) {
  return CommunityRemoteDataSource(getIt<DioService>());
});

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  final remoteDataSource = ref.watch(communityRemoteDataSourceProvider);
  return CommunityRepositoryImpl(remoteDataSource);
});

final communityPostsProvider = FutureProvider.family<List<PostModel>, int>((ref, page) async {
  final repository = ref.watch(communityRepositoryProvider);
  final response = await repository.getPosts(page: page);
  return response.items;
});

final postCommentsProvider = FutureProvider.family<List<CommentModel>, ({int postId, int page})>((ref, params) async {
  final repository = ref.watch(communityRepositoryProvider);
  final response = await repository.getComments(postId: params.postId, page: params.page);
  return response.items;
});
