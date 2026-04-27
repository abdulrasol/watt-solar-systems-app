import 'dart:io';

import 'package:solar_hub/src/features/company_work/domain/entities/company_work.dart';

abstract class CompanyWorkRepository {
  Future<List<CompanyWork>> getPublicWorks(
    int companyId, {
    required int page,
    int? pageSize,
  });

  Future<int> getPublicWorksCount(
    int companyId, {
    required int page,
    int? pageSize,
  });

  Future<List<CompanyWork>> getCompanyWorks(
    int companyId, {
    required int page,
    int? pageSize,
  });

  Future<int> getCompanyWorksCount(
    int companyId, {
    required int page,
    int? pageSize,
  });

  Future<CompanyWork> createWork(
    int companyId,
    Map<String, dynamic> payload, {
    List<File> images = const [],
  });

  Future<CompanyWork> updateWork(
    int companyId,
    int workId,
    Map<String, dynamic> payload, {
    List<File> images = const [],
  });

  Future<void> deleteWork(int companyId, int workId);

  Future<void> deleteWorkImage(int companyId, int imageId);
}
