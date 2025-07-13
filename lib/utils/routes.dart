import 'package:get/get.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:solar_hub/layouts/calculator/battery_calculator/battrey_calculator.dart';
import 'package:solar_hub/layouts/calculator/calculator.dart';
import 'package:solar_hub/layouts/calculator/inverter_calculator.dart';
import 'package:solar_hub/layouts/calculator/panel_calculator.dart';
import 'package:solar_hub/layouts/home.dart';
import 'package:solar_hub/layouts/hub/community_share/notifications.dart';
import 'package:solar_hub/layouts/hub/community_share/post_details_page.dart';
import 'package:solar_hub/layouts/hub/community_share/system_details_page.dart';

class AppRoutes {
  static final routes = <GetPage>[
    GetPage(
      name: '/calculator',
      page: () => const Calculator(),
      transition: Transition.cupertino,
    ),

    GetPage(name: '/home', page: () => Home()),

    // calculations
    GetPage(
      name: '/calculator/panel',
      page: () => PanelCalculator(),
      transition: Transition.fade,
    ),
    GetPage(
      name: '/calculator/battery',
      page: () => BatteryCalculator(),
      transition: Transition.fade,
    ),
    GetPage(
      name: '/calculator/inverter',
      page: () => InverterCalculator(),
      transition: Transition.fade,
    ),
    GetPage(
      name: '/community/post',
      page: () => PostDetailsPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: '/community/system',
      page: () => SystemDetailsPage(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: '/community/notifications',
      page: () => NotificationsScreen(),
      transition: Transition.upToDown,
    ),

    // GetPage(name: '/wires', page: () => WiresCalculator()),
    // GetPage(name: '/direction', page: () => DirectionCalculator()),
    // GetPage(name: '/pump', page: () => PumpCalculator()),
    // // community shareing
    // GetPage(name: '/community', page: () => CommunityShare()),
    // GetPage(name: '/user-system', page: () => UserSystem()),
    // GetPage(name: '/user-system-input', page: () => UserSystemInput()),

    // GetPage(name: '/auth', page: () => AuthPage()),
  ];
}
