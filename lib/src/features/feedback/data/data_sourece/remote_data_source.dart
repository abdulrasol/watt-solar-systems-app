import 'package:dartz/dartz.dart';
import 'package:solar_hub/src/core/errors/failure.dart';
import 'package:solar_hub/src/features/feedback/domain/entities/feedback_entity.dart';

abstract class RemoteDataSource {
  Future<Either<Failure, List<FeedbackEntity>>> fetchFeedbacks();
}
