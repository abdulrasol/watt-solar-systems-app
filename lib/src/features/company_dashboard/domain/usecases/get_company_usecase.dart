import 'package:dartz/dartz.dart';
import 'package:solar_hub/src/core/errors/failure.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/summery.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/repositories/dashboard_repository.dart';

class GetCompanySummeryUseCase {
  final CompanySummeryRepository repository;

  GetCompanySummeryUseCase({required this.repository});

  Future<Either<Failure, CompanySummery>> call(int id) async {
    return await repository.getCompanySummery(id);
  }
}
