import 'package:dartz/dartz.dart';
import 'package:solar_hub/src/core/errors/failure.dart';
import 'package:solar_hub/src/features/company_dashboard/data/datasources/local_datasource.dart';
import 'package:solar_hub/src/features/company_dashboard/data/datasources/remote_datasource.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/summery.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/repositories/dashboard_repository.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class CompanySummeryRepositoryImpl implements CompanySummeryRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;

  CompanySummeryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, CompanySummery>> getCompanySummery(int id) async {
    final result = await remoteDataSource.getCompanySummery(id);
    result.fold(
      (l) {
        dPrint(l);
        return l;
      },
      (r) {
        dPrint(r);
        return r;
      },
    );
    return result.fold(
      (failure) async {
        // Remote failed, try local cache
        try {
          final localData = await localDataSource.getCompanySummery(id);
          return Right(localData);
        } catch (e) {
          // Both failed
          return Left(failure);
        }
      },
      (summery) async {
        // Remote success, update cache
        await localDataSource.saveCompanySummery(id, summery);
        return Right(summery);
      },
    );
  }
}
