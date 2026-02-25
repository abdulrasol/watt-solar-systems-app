import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:solar_hub/features/auth/models/company.dart';
import 'package:solar_hub/features/auth/models/user.dart';
import 'package:solar_hub/features/auth/models/user_permissions.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();
  final Rx<User?> user = Rx<User?>(null);
  final Rx<Company?> company = Rx<Company?>(null);
  late RxBool isSigned = false.obs;
  late RxString token = ''.obs;
  late GetStorage box;

  @override
  void onInit() {
    super.onInit();
    box = GetStorage();
    
    isSigned.value = box.read('token') != null;
    token.value = box.read('token') ?? '';
    company.value = box.read('company') != null ? Company.fromJson(box.read('company')) : null;
    user.value = box.read('user') != null ? User.fromJson(box.read('user')) : null;
    box.listenKey('token', (value) {
      if (value != null) {
        isSigned.value = true;
        token.value = value;
      } else {
        isSigned.value = false;
        token.value = '';
      }
    });

    box.listenKey('company', (value) {
      if (value != null) {
        company.value = Company.fromJson(value);
      } else {
        company.value = null;
      }
    });

    box.listenKey('user', (value) {
      if (value != null) {
        user.value = User.fromJson(value);
      } else {
        user.value = null;
      }
    });

    ever(user, (value) {
      fetchUserRole();
    });
  }

  @override
  void onReady() {
    super.onReady();
    fetchUserRole();
  }

  final role = 'user'.obs;

  UserPermissions get permissions => UserPermissions.fromJson(box.read('permissions'));
  bool get canEdit => false; // TODO: implement

  Future<void> fetchUserRole() async {
    if (user.value?.isSuperUser == true) {
      role.value = 'admin';
      return;
    } else if (user.value?.company != null) {
      role.value = 'company_member';
      return;
    } else {
      role.value = 'user';
      return;
    }
  }
}
