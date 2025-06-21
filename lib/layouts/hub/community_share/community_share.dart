import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/layouts/widgets/post_card.dart';
import 'package:solar_hub/layouts/widgets/system_card_widget.dart';

class CommunityShare extends StatefulWidget {
  const CommunityShare({super.key});

  @override
  State<CommunityShare> createState() => _CommunityShareState();
}

class _CommunityShareState extends State<CommunityShare>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> fakePosts = [post, post2];

  final List<Map<String, dynamic>> fakeSystems = [system];

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Solar Hub Community",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ), //     style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        //  backgroundColor: Colors.orange.shade700,
        centerTitle: true,

        titleSpacing: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Systems".tr),
            Tab(text: "Posts".tr),
            Tab(text: "problems".tr),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: User Systems
          ListView(
            padding: const EdgeInsets.all(12),
            children: fakeSystems
                .map((system) => systemCard(context, system))
                .toList(),
          ),
          // Tab 2: Posts
          ListView(
            padding: const EdgeInsets.all(12),
            children: fakePosts
                .where((post) => post["type"] != "issue")
                .map((post) => postCard(post))
                .toList(),
          ),
          // Tab 3: Issues
          ListView(
            padding: const EdgeInsets.all(12),
            children: fakePosts
                .where((post) => post["type"] == "issue")
                .map((post) => postCard(post))
                .toList(),
          ),
        ],
      ),
    );
  }
}

final system = {
  'userName': 'Rasool Al-Engineer',
  'type': 'Hybrid',
  'panelPower': 610,
  'panelCount': 6,
  'panelBrand': 'LONGi',
  'panelNotes': 'Mounted at 25° tilt',
  'batteryVoltage': 51.2,
  'batteryAh': 200,
  'batteryCount': 1,
  'batteryBrand': 'SVolt',
  'batteryNotes': 'Lithium, safe under high temp',
  'inverterSize': '6',
  'inverterType': 'Hybrid',
  'inverterBrand': 'Deye',
  'inverterNotes': 'WiFi monitoring enabled',
  'installDate': '2024-11-10',
  'installer': 'SolarTech Iraq',
  'relatedPosts': [post, post2],
};
final post = {
  'title': 'Battery Drain Problem',
  'user': 'Ahmed Zain',
  "type": "post",
  'date': '2025-04-15',
  'content': 'The battery drains quickly after sunset.',
  'likes': 5,
  'dislikes': 2,
  'comments': [
    {
      'author': 'Engineer Noor',
      'text': 'Check your charge controller!',
      'timestamp': '2025-04-16',
    },
    {
      'author': 'Ali H.',
      'text': 'Had same issue with old inverter',
      'timestamp': '2025-04-17',
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
    'installer': 'GreenSun Co.',
  },
};
final post2 = {
  'title': 'شحن غير كافي',
  'user': 'الحلو',
  "type": "issue",
  'date': '2025-04-15',
  'content': 'في الليل يكون التشغيل اقل من المعتاد على البطارية',
  'likes': 5,
  'dislikes': 2,
  'comments': [
    {
      'author': 'Engineer Noor',
      'text': 'Check your charge controller!',
      'timestamp': '2025-04-16',
    },
    {
      'author': 'Ali H.',
      'text': 'Had same issue with old inverter',
      'timestamp': '2025-04-17',
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
    'installer': 'GreenSun Co.',
  },
};
