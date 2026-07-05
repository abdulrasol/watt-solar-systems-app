import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/posters/data/data_sources/poster_remote_data_source.dart';
import 'package:solar_hub/src/features/posters/domain/entities/poster_entity.dart';

final activePostersProvider = FutureProvider<List<PosterEntity>>((ref) async {
  final dataSource = getIt<PosterRemoteDataSource>();
  final models = await dataSource.fetchActivePosters();
  return models.map((m) => m.toEntity()).toList();
});
