import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entites/dashboard.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/repositories/dashboard_repository.dart';

final dashboardDataProvider = FutureProvider<Dashboard>((ref) async {
  return await getIt<DashboardRepository>().getDashboard(ref.read(authProvider).company!.id);
});


