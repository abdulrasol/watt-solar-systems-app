import 'package:dartz/dartz.dart';
import 'package:solar_hub/src/core/errors/failure.dart';
import 'package:solar_hub/src/features/splash/domain/entities/config.dart';

abstract class AppInitRepository {
  Future<Either<Failure, List<Config>>> getConfigs();
}