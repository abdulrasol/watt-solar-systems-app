import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget postCard(Map<String, dynamic> post) {
  return InkWell(
    onTap: () {
      Get.toNamed('/community/post', arguments: post);
    },
    child: Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title:
            Text(post["title"], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(post["content"]),
        leading: CircleAvatar(child: Text(post["user"][0])),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("💬 ${post["comments"].length}"),
          ],
        ),
      ),
    ),
  );
}

final post = {
  'title': 'Battery Drain Problem',
  'author': 'Ahmed Zain',
  'date': '2025-04-15',
  'content': 'The battery drains quickly after sunset.',
  'likes': 5,
  'dislikes': 2,
  'comments': [
    {
      'author': 'Engineer Noor',
      'text': 'Check your charge controller!',
      'timestamp': '2025-04-16'
    },
    {
      'author': 'Ali H.',
      'text': 'Had same issue with old inverter',
      'timestamp': '2025-04-17'
    },
  ],
  'system': {
    'panelCount': 4,
    'panelPower': '550W',
    'panelBrand': 'Jinko',
    'batteryCount': 2,
    'batteryAh': '250',
    'batteryBrand': 'Narada',
    'inverterSize': '5kW',
    'inverterBrand': 'Growatt',
    'installer': 'GreenSun Co.'
  },
};
