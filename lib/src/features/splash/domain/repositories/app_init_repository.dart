import 'package:dartz/dartz.dart';
import 'package:solar_hub/src/core/errors/failure.dart';
import 'package:solar_hub/src/features/splash/domain/entities/config_snapshot.dart';

abstract class AppInitRepository {
  Future<Either<Failure, ConfigSnapshot>> getCachedConfigs();

  Future<Either<Failure, ConfigSnapshot>> refreshConfigs();
}
