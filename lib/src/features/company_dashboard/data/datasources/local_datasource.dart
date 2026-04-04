import 'dart:convert';

import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/summery.dart';

abstract class LocalDataSource {
  Future<CompanySummery> getCompanySummery(int id);
  Future<void> saveCompanySummery(int id, CompanySummery summery);
}

class LocalDataSourceImpl implements LocalDataSource {
  final CasheInterface casheInterface;
  LocalDataSourceImpl({required this.casheInterface});

  @override
  Future<CompanySummery> getCompanySummery(int id) async {
    final json = casheInterface.get('company_summery_$id');
    if (json == null) {
      throw Exception('Company summery not found');
    }
    return CompanySummery.fromJson(jsonDecode(json));
  }

  @override
  Future<void> saveCompanySummery(int id, CompanySummery summery) async {
    await casheInterface.save('company_summery_$id', summery.toJson());
  }
}
