import 'package:dartz/dartz.dart';
import 'package:watt/src/core/errors/failure.dart';
import 'package:watt/src/features/company_dashboard/data/data_sources/local_datasource.dart';
import 'package:watt/src/features/company_dashboard/data/data_sources/remote_datasource.dart';
import 'package:watt/src/features/company_dashboard/domain/entities/summary.dart';
import 'package:watt/src/features/company_dashboard/domain/repositories/dashboard_repository.dart';

class CompanySummaryRepositoryImpl implements CompanySummaryRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;

  CompanySummaryRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, CompanySummary>> getCompanySummary(int id) async {
    final result = await remoteDataSource.getCompanySummary(id);
    return result.fold(
      (failure) async {
        if (failure is! NetworkFailure) {
          return Left(failure);
        }

        try {
          final localData = await localDataSource.getCompanySummary(id);
          return Right(localData);
        } catch (e) {
          return Left(failure);
        }
      },
      (summary) async {
        // Remote success, update cache
        await localDataSource.saveCompanySummary(id, summary);
        return Right(summary);
      },
    );
  }
}
