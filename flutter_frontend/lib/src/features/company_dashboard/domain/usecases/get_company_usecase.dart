import 'package:dartz/dartz.dart';
import 'package:watt/src/core/errors/failure.dart';
import 'package:watt/src/features/company_dashboard/domain/entities/summary.dart';
import 'package:watt/src/features/company_dashboard/domain/repositories/dashboard_repository.dart';

class GetCompanySummaryUseCase {
  final CompanySummaryRepository repository;

  GetCompanySummaryUseCase({required this.repository});

  Future<Either<Failure, CompanySummary>> call(int id) async {
    return await repository.getCompanySummary(id);
  }
}
