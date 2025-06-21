import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/utils/app_constants.dart';
import 'package:solar_hub/layouts/widgets/text_helper_card.dart';

class PumpCalculator extends StatefulWidget {
  const PumpCalculator({super.key});

  @override
  State<PumpCalculator> createState() => _PumpCalculatorState();
}

class _PumpCalculatorState extends State<PumpCalculator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solar Pump System'),
        actions: [
          TextButton.icon(
            onPressed: () {
              // _updateData();
            },
            label: Text('Save'),
            icon: Icon(IonIcons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Form(
                  //key: key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Hero(
                        tag: '/pump',
                        child: Image.asset(
                          'assets/png/cards/pump.png',
                          height: 180,
                        ),
                      ),
                      verSpace(),
                      textHelperCard(
                        context,
                        text: 'nuder creation',
                        title: 'not yet',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
