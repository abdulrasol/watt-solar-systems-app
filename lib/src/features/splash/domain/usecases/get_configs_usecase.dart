import 'package:dartz/dartz.dart';
import 'package:solar_hub/src/core/errors/failure.dart';
import 'package:solar_hub/src/features/splash/domain/entities/config.dart';
import 'package:solar_hub/src/features/splash/domain/repositories/app_init_repository.dart';

class GetConfigsUseCase {
  final AppInitRepository repository;

  GetConfigsUseCase(this.repository);

  Future<Either<Failure, List<Config>>> call() async {
    return await repository.getConfigs();
  }
}
