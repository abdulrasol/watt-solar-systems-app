import 'package:dartz/dartz.dart';
import 'package:watt/src/core/errors/failure.dart';
import 'package:watt/src/features/company_dashboard/domain/entities/summary.dart';

abstract class CompanySummaryRepository {
  Future<Either<Failure, CompanySummary>> getCompanySummary(int id);
}
