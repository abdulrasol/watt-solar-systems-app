import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/features/pv_system_designer/data/data_sources/open_meteo_solar_data_source.dart';
import 'package:solar_hub/src/features/pv_system_designer/data/repositories/solar_data_repository_impl.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/repositories/solar_data_repository.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/services/pv_system_calculator.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/controllers/pv_system_design_controller.dart';

/// A plain Dio instance for external Open-Meteo calls.
final _openMeteoDioProvider = Provider<Dio>((ref) => Dio());

final openMeteoSolarDataSourceProvider = Provider<OpenMeteoSolarDataSource>(
  (ref) => OpenMeteoSolarDataSource(dio: ref.watch(_openMeteoDioProvider)),
);

final solarDataRepositoryProvider = Provider<SolarDataRepository>(
  (ref) => SolarDataRepositoryImpl(
    dataSource: ref.watch(openMeteoSolarDataSourceProvider),
  ),
);

final pvSystemCalculatorProvider = Provider<PvSystemCalculator>(
  (ref) => PvSystemCalculator(
    solarDataRepository: ref.watch(solarDataRepositoryProvider),
  ),
);

final pvSystemDesignControllerProvider = NotifierProvider<
    PvSystemDesignController, PvSystemDesignState>(
  () => PvSystemDesignController(),
);
