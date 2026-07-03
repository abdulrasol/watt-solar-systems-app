import 'dart:io';

import 'package:solar_hub/src/features/company_work/data/data_sources/company_work_remote_data_source.dart';
import 'package:solar_hub/src/features/company_work/domain/entities/company_work.dart';
import 'package:solar_hub/src/features/company_work/domain/repositories/company_work_repository.dart';

class CompanyWorkRepositoryImpl implements CompanyWorkRepository {
  CompanyWorkRepositoryImpl(this._remoteDataSource);

  final CompanyWorkRemoteDataSource _remoteDataSource;

  @override
  Future<List<CompanyWork>> getPublicWorks(
    int companyId, {
    required int page,
    int? pageSize,
  }) async {
    final (items, _) = await _remoteDataSource.getPublicWorks(
      companyId,
      page: page,
      pageSize: pageSize,
    );
    return items;
  }

  @override
  Future<int> getPublicWorksCount(
    int companyId, {
    required int page,
    int? pageSize,
  }) async {
    final (_, count) = await _remoteDataSource.getPublicWorks(
      companyId,
      page: page,
      pageSize: pageSize,
    );
    return count;
  }

  @override
  Future<List<CompanyWork>> getCompanyWorks(
    int companyId, {
    required int page,
    int? pageSize,
  }) async {
    final (items, _) = await _remoteDataSource.getCompanyWorks(
      companyId,
      page: page,
      pageSize: pageSize,
    );
    return items;
  }

  @override
  Future<int> getCompanyWorksCount(
    int companyId, {
    required int page,
    int? pageSize,
  }) async {
    final (_, count) = await _remoteDataSource.getCompanyWorks(
      companyId,
      page: page,
      pageSize: pageSize,
    );
    return count;
  }

  @override
  Future<CompanyWork> createWork(
    int companyId,
    Map<String, dynamic> payload, {
    List<File> images = const [],
  }) {
    return _remoteDataSource.createWork(companyId, payload, images: images);
  }

  @override
  Future<CompanyWork> updateWork(
    int companyId,
    int workId,
    Map<String, dynamic> payload, {
    List<File> images = const [],
  }) {
    return _remoteDataSource.updateWork(
      companyId,
      workId,
      payload,
      images: images,
    );
  }

  @override
  Future<void> deleteWork(int companyId, int workId) {
    return _remoteDataSource.deleteWork(companyId, workId);
  }

  @override
  Future<void> deleteWorkImage(int companyId, int imageId) {
    return _remoteDataSource.deleteWorkImage(companyId, imageId);
  }
}
