import 'package:solar_hub/src/features/company_dashboard/domain/entites/dashboard.dart';

abstract class DashboardRepository {
  Future<Dashboard> getDashboard(int id);
}
