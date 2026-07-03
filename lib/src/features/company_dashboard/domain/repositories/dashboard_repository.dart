import 'package:dartz/dartz.dart';
import 'package:solar_hub/src/core/errors/failure.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/summary.dart';

abstract class CompanySummaryRepository {
  Future<Either<Failure, CompanySummary>> getCompanySummary(int id);
}
