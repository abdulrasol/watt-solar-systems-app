import 'package:solar_hub/src/features/company_dashboard/data/datasource/dashboard_remote_datastore.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entites/dashboard.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDatastore _dashboardRemoteDatastore;
  DashboardRepositoryImpl(this._dashboardRemoteDatastore);
  @override
  Future<Dashboard> getDashboard(int id) async {
    return await _dashboardRemoteDatastore.getDashboard(id);
  }
}
