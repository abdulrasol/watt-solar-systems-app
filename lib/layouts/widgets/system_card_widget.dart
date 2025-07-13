import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/layouts/widgets/system_page_info_card_widget.dart';

Widget systemCard(context, Map<String, dynamic> system) {
  return InkWell(
    onTap: () {
      Get.toNamed('/community/system', arguments: system);
    },
    child: Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: sectionTitle(system["user_name"]!),
        //Text(system["userName"]!,
        //   style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                runAlignment: WrapAlignment.spaceBetween,
                spacing: 5,
                runSpacing: 5,
                children: [
                  infoRow(
                    'Panels',
                    "${(system["panelCount"] * system["panelPower"]) / 1000} KW",
                  ),
                  infoRow('Inverter', "${system["inverterSize"]} KW"),
                  infoRow(
                    'Battery',
                    "${(system["batteryAh"]) * (system["batteryCount"]) * (system["batteryVoltage"]) / 1000} KW",
                  ),
                ],
              ),
            ),
            Divider(thickness: 1, color: Theme.of(context).primaryColor),
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                runAlignment: WrapAlignment.spaceBetween,
                spacing: 5,
                runSpacing: 5,
                children: [
                  infoRow('Date', system['installDate']),
                  if (system['installer'] != null &&
                      system['installer'].toString().isNotEmpty)
                    infoRow('Installer', system['installer']),
                ],
              ),
            ),
          ],
        ),
        leading: Image.asset('assets/png/cards/load.png'),
      ),
    ),
  );
}
