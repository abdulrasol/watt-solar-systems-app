import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/errors/failure.dart';
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/summary.dart';
import 'package:solar_hub/src/utils/app_urls.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

abstract class RemoteDataSource {
  Future<Either<Failure, CompanySummary>> getCompanySummary(int id);
}

class RemoteDataSourceImpl implements RemoteDataSource {
  late final DioService dioService;

  RemoteDataSourceImpl() {
    dioService = getIt<DioService>();
  }

  @override
  Future<Either<Failure, CompanySummary>> getCompanySummary(int id) async {
    try {
      final response = await dioService.get(AppUrls.companySummary(id));
      return Right(CompanySummary.fromJson(response.body));
    } on DioException catch (e, stackTrace) {
      dPrint(
        'getCompanySummary DioException: $e',
        stackTrace: stackTrace,
        tag: 'RemoteDataSource',
      );
      final message =
          e.response?.data?['message_user'] ??
          e.response?.data?['message'] ??
          e.message ??
          e.toString();
      if (_isConnectivityError(e)) {
        return Left(NetworkFailure(message));
      }
      return Left(ServerFailure(message));
    } catch (e, stackTrace) {
      dPrint(
        'getCompanySummary error: $e',
        stackTrace: stackTrace,
        tag: 'RemoteDataSource',
      );
      return Left(ServerFailure(e.toString()));
    }
  }

  bool _isConnectivityError(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
  }
}
