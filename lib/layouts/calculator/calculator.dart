import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/layouts/widgets/home_card_widget.dart';

class Calculator extends StatelessWidget {
  const Calculator({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_FeatureCard> features = [
      _FeatureCard(
        'panel-calculator'.tr,
        'assets/png/cards/panels.png',
        '/calculator/panel',
        false,
      ),
      _FeatureCard(
        "battery-calculator".tr,
        'assets/png/cards/battery.png',
        '/calculator/battery',
        false,
      ),

      _FeatureCard(
        'Inverter And Charging'.tr,
        'assets/png/cards/inverter.png',
        '/calculator/inverter',
        false,
      ),

      _FeatureCard(
        "angle-direction-calculation",
        'assets/png/cards/direction.png',
        '/direction',
        false,
      ),
      // _FeatureCard(
      //   "my-system",
      //   'assets/png/cards/housing.png',
      //   '/user-system',
      //   true,
      // ),
      _FeatureCard(
        "wire-calculator'",
        'assets/png/cards/wiring.png',
        '/wires',
        true,
      ),
      _FeatureCard(
        "pump-calculator",
        'assets/png/cards/pump.png',
        '/pump',
        false,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Solar Hub Calculator',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: features.map((feature) {
            return homeCardWidget(feature);
          }).toList(),
        ),
      ),
      // drawer: drawer(),
    );
  }
}

class _FeatureCard {
  final String title;
  final String image;
  final String route;
  final bool signInRequied;

  _FeatureCard(this.title, this.image, this.route, this.signInRequied);
}
