// import 'package:get/get.dart';
// import 'package:solar_hub/core/cashe/cashe_interface.dart';
// import 'package:solar_hub/core/di/get_it.dart';
// import 'package:solar_hub/features/auth/controllers/company_controller.dart';
// import 'package:solar_hub/features/auth/models/user.dart';
// import 'package:solar_hub/features/auth/services/auth_services.dart';

// class AuthController extends GetxController {
//   static AuthController get to => Get.find();
//   final Rx<User?> user = Rx<User?>(null);
//   late RxBool isSigned = false.obs;
//   late RxString token = ''.obs;
//   late CasheInterface cashe;

//   @override
//   void onInit() {
//     super.onInit();
//     cashe = getIt<CasheInterface>();
//     isSigned.value = cashe.get('token') != null;
//     token.value = cashe.get('token') ?? '';
//     user.value = cashe.get('user') != null ? User.fromJson(cashe.get('user')) : null;
//     cashe.box.listenKey('token', (value) {
//       if (value != null) {
//         isSigned.value = true;
//         token.value = value;
//       } else {
//         isSigned.value = false;
//         token.value = '';
//       }
//     });

//     cashe.box.listenKey('user', (value) {
//       if (value != null) {
//         user.value = User.fromJson(value);
//       } else {
//         user.value = null;
//       }
//     });

//     fetchUserRole();
//   }

//   // @override
//   // void onReady() {
//   //   super.onReady();
//   // }

//   final role = 'user'.obs;

//   CompanyController get companyController => getIt<CompanyController>();

//   Future<void> fetchUserRole() async {
//     await getIt<AuthServices>().fetchProfile();
//     if (user.value?.isSuperUser == true) {
//       role.value = 'admin';
//       return;
//     } else if (user.value?.company != null) {
//       role.value = 'company_member';
//       return;
//     } else {
//       role.value = 'user';
//       return;
//     }
//   }
// }
