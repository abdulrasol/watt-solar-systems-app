// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:icons_plus/icons_plus.dart';
// import 'package:solar_hub/controllers/auth_controller.dart';

// AuthController authController = Get.find();

// Drawer drawer() {
//   return Drawer(
//     child: Center(
//       child: Column(
//         children: [
//           DrawerHeader(
//             // decoration: BoxDecoration(color: Colors.teal),
//             child: Column(
//               children: [
//                 CircleAvatar(
//                   radius: 48,
//                   child: Image.asset(
//                     'assets/png/logo.png',
//                   ),
//                 )
//               ],
//             ),
//           ),
//           Spacer(),
//           Obx(
//             () => ListTile(
//               title: Text(
//                   authController.isSignedIn.value ? 'Sign Out' : 'Sign In'),
//               leading: Icon(authController.isSignedIn.value
//                   ? IonIcons.log_out
//                   : IonIcons.log_in),
//               onTap: () async {
//                 if (!await authController.checkLoginState()) {
//                   Get.toNamed('/auth');
//                 } else {
//                   await authController.logOut();
//                 }
//               },
//             ),
//           )
//         ],
//       ),
//     ),
//   );
// }
