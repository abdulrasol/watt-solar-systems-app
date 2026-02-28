// import 'package:get/get.dart';
// import 'package:solar_hub/core/cashe/cashe_interface.dart';
// import 'package:solar_hub/core/di/get_it.dart';
// import 'package:solar_hub/features/auth/controllers/auth_controller.dart';
// import 'package:solar_hub/features/auth/models/company.dart';
// import 'package:solar_hub/features/auth/models/user_permissions.dart';

// class CompanyController extends GetxController {
//   final Rx<Company?> company = Rx<Company?>(null);
//   final authController = AuthController.to;
//   final cashe = getIt<CasheInterface>();

//   @override
//   void onInit() {
//     super.onInit();
//     company.value = cashe.get('company') != null ? Company.fromJson(cashe.get('company')) : null;

//     cashe.box.listenKey('company', (value) {
//       if (value != null) {
//         company.value = Company.fromJson(value);
//       } else {
//         company.value = null;
//       }
//     });
//   }

//   bool get isCompanyMember => authController.user.value?.company != null;

//   UserPermissions get permissions => UserPermissions.fromJson(cashe.get('permissions'));

//   bool canEdit(String permission) {
//     if (!isCompanyMember) {
//       return false;
//     }
//     if (authController.role.value == 'admin' || authController.role.value == 'manager') {
//       return true;
//     }
//     return permissions.canEdit(permission);
//   }

//   bool canRead(String permission) {
//     if (!isCompanyMember) {
//       return false;
//     }
//     if (authController.role.value == 'admin' || authController.role.value == 'manager') {
//       return true;
//     }
//     return permissions.canRead(permission);
//   }
// }
