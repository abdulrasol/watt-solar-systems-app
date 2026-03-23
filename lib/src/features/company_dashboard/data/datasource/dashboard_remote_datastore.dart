import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/features/auth/data/models/dashboard_model.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entites/dashboard.dart';
import 'package:solar_hub/src/utils/app_urls.dart';

abstract class DashboardRemoteDatastore {
  Future<Dashboard> getDashboard(int id);
}

class DashboardRemoteDatastoreImpl implements DashboardRemoteDatastore {
  final DioService _dioService;
  DashboardRemoteDatastoreImpl(this._dioService);
  @override
  Future<Dashboard> getDashboard(int id) async {
    BaseResponse response = await _dioService.post(AppUrls.company(id));
    if (response.status != 200 || response.error) {
      throw Exception(response.messageUser);
    }

    return DashboardModel.fromJson(response.body);
  }
}
