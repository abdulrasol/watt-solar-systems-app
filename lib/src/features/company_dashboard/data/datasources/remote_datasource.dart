import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/errors/failure.dart';
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/service.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/summery.dart';
import 'package:solar_hub/src/utils/app_urls.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

abstract class RemoteDataSource {
  Future<Either<Failure, CompanySummery>> getCompanySummery(int id);
  Future<Either<Failure, CompanyService>> requestService(
    int companyId,
    String serviceCode,
  );
}

class RemoteDataSourceImpl implements RemoteDataSource {
  late final DioService dioService;

  RemoteDataSourceImpl() {
    dioService = getIt<DioService>();
  }

  @override
  Future<Either<Failure, CompanySummery>> getCompanySummery(int id) async {
    try {
      final response = await dioService.get(AppUrls.companySummary(id));
      return Right(CompanySummery.fromJson(response.body));
    } on DioException catch (e, stackTrace) {
      dPrint(
        'getCompanySummery DioException: $e',
        stackTrace: stackTrace,
        tag: 'RemoteDataSource',
      );
      final message =
          e.response?.data?['message_user'] ??
          e.response?.data?['message'] ??
          e.message ??
          e.toString();
      return Left(ServerFailure(message));
    } catch (e, stackTrace) {
      dPrint(
        'getCompanySummery error: $e',
        stackTrace: stackTrace,
        tag: 'RemoteDataSource',
      );
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompanyService>> requestService(
    int companyId,
    String serviceCode,
  ) async {
    try {
      final response = await dioService.post(
        AppUrls.companyServiceRequests(companyId),
        data: {'service_code': serviceCode, 'notes': 'Requested by user'},
      );
      return Right(CompanyService.fromJson(response.body));
    } on DioException catch (e, stackTrace) {
      dPrint(
        'requestService DioException: $e',
        stackTrace: stackTrace,
        tag: 'RemoteDataSource',
      );
      final message =
          e.response?.data?['message_user'] ??
          e.response?.data?['message'] ??
          e.message ??
          e.toString();
      return Left(ServerFailure(message));
    } catch (e, stackTrace) {
      dPrint(
        'requestService error: $e',
        stackTrace: stackTrace,
        tag: 'RemoteDataSource',
      );
      return Left(ServerFailure(e.toString()));
    }
  }
}
