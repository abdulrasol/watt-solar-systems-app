import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
//import 'package:solar_hub/controllers/data_controller.dart';
import 'package:solar_hub/utils/app_constants.dart';
import 'package:solar_hub/layouts/calculator/battery_calculator/count_calculator.dart';
import 'package:solar_hub/layouts/calculator/battery_calculator/time_calculator.dart';

//final DataController dataContrller = Get.find();

class BatteryCalculator extends StatefulWidget {
  const BatteryCalculator({super.key});

  @override
  State<BatteryCalculator> createState() => _BatteryCalculatorState();
}

class _BatteryCalculatorState extends State<BatteryCalculator> {
  // ui
  Map<String, dynamic> battreyData = {};
  int pageSelector = 0;
  List<Widget> pages = [TimeCalculator(), CountCalculator()];
  GlobalKey<FormState> key = GlobalKey<FormState>();
  // calculations

  Widget divider = Column(
    children: [
      Divider(thickness: 1, color: Color(0x4000C3FF)),
      verSpace(),
    ],
  );

  @override
  void initState() {
    super.initState();
    var a = {
      'user-current': 0,
      'ac-voltage-system': 230,
      'user-battery-voltage': 0,
      'user-battery-ampere': 0,
      'user-battery-count': 0,
      'user-battery-depht': 0,
      'user-battery-runtime': 0,
      'user-charge-current': 0,
    };
    // dataContrller.batteryCalculatedData.value =
    //     dataContrller.userCalculatedSystem.value['battery'] ?? a;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('battery-calculator'.tr),
        actions: [
          TextButton.icon(
            onPressed: () {
              if (key.currentState!.validate()) {
                // dataContrller
                //     .updateUserCalculatedSystemData(
                //       UserSystemDataPart.battery,
                //       dataContrller.batteryCalculatedData.value,
                //     )
                //     .then(
                //       (onValue) => Get.snackbar(
                //         'Battery',
                //         'data saved successfully',
                //         icon: Icon(IonIcons.save),
                //       ),
                //     );
              }
            },
            label: Text('Save'),
            icon: Icon(IonIcons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            verSpace(),
            // Hero(
            //   tag: '/battery',
            //   child: Image.asset('assets/png/cards/battery.png', height: 180),
            // ).animate().fade(duration: 500.ms).slideY(begin: -0.1),
            verSpace(space: 10),
            Expanded(
              child: Form(key: key, child: pages[pageSelector]),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageSelector,
        onTap: (value) => setState(() {
          pageSelector = value;
        }),
        items: [
          BottomNavigationBarItem(
            icon: Icon(IonIcons.timer),
            label: 'time-calculate'.tr,
            tooltip: 'calculate battery runing time in gevin Power',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesome.car_battery_solid),
            label: 'count-calculate'.tr,
            tooltip:
                'calculate battery capacity for gevin power and runing time',
          ),
        ],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }
}
