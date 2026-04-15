import 'package:dartz/dartz.dart';
import 'package:solar_hub/src/core/errors/failure.dart';
import 'package:solar_hub/src/features/splash/domain/entities/config_snapshot.dart';
import 'package:solar_hub/src/features/splash/domain/repositories/app_init_repository.dart';

class RefreshConfigsUseCase {
  final AppInitRepository repository;

  RefreshConfigsUseCase(this.repository);

  Future<Either<Failure, ConfigSnapshot>> call() async {
    return repository.refreshConfigs();
  }
}
