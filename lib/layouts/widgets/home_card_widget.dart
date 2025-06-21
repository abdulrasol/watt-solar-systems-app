import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:get/get.dart';
// import 'package:icons_plus/icons_plus.dart';
// import 'package:solar_hub/controllers/auth_controller.dart';

//AuthController authController = Get.find();

InkWell homeCardWidget(feature) {
  return InkWell(
    onTap: () async {
      //if (feature.signInRequied) {
      //   if (await authController.checkLoginState()) {
      //     Get.toNamed(feature.route);
      //   } else {
      //     Get.snackbar(
      //       'Login required!',
      //       'to view and share your system shoud login first',
      //       icon: Icon(IonIcons.log_in),
      //       mainButton: TextButton(
      //           onPressed: () {
      //             Get.toNamed('/auth');
      //           },
      //           child: Text('Login')),
      //     );
      //   }
      // } else {
      print(feature.route);
      Get.toNamed(feature.route);
      // }
    },
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.amber.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity / 4,
            height: 48,
            child: Hero(tag: feature.route, child: Image.asset(feature.image)),
          ),
          SizedBox(height: 12),
          Text(
            feature.title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}
