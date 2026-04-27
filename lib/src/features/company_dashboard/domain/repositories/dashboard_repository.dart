import 'package:dartz/dartz.dart';
import 'package:solar_hub/src/core/errors/failure.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/summery.dart';

abstract class CompanySummeryRepository {
  Future<Either<Failure, CompanySummery>> getCompanySummery(int id);
}
