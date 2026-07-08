import 'dart:convert';

import 'package:watt/src/core/cashe/cashe_interface.dart';
import 'package:watt/src/features/company_dashboard/domain/entities/summary.dart';
import 'package:watt/src/utils/helper_methods.dart';

abstract class LocalDataSource {
  Future<CompanySummary> getCompanySummary(int id);
  Future<void> saveCompanySummary(int id, CompanySummary summary);
}

class LocalDataSourceImpl implements LocalDataSource {
  final CasheInterface casheInterface;
  LocalDataSourceImpl({required this.casheInterface});

  @override
  Future<CompanySummary> getCompanySummary(int id) async {
    try {
      final cached = casheInterface.get('company_summary_$id');
      if (cached == null) {
        throw Exception('Company summary not found');
      }
      return CompanySummary.fromJson(_decodeSummary(cached));
    } catch (e, stackTrace) {
      dPrint(
        'getCompanySummary error: $e',
        stackTrace: stackTrace,
        tag: 'LocalDataSourceImpl',
      );
      rethrow;
    }
  }

  @override
  Future<void> saveCompanySummary(int id, CompanySummary summary) async {
    try {
      await casheInterface.save('company_summary_$id', summary.toJson());
    } catch (e, stackTrace) {
      dPrint(
        'saveCompanySummary error: $e',
        stackTrace: stackTrace,
        tag: 'LocalDataSourceImpl',
      );
      rethrow;
    }
  }

  Map<String, dynamic> _decodeSummary(dynamic cached) {
    if (cached is String) {
      final decoded = jsonDecode(cached);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }

    if (cached is Map) {
      return Map<String, dynamic>.from(cached);
    }

    throw Exception('Invalid company summary cache payload');
  }
}
