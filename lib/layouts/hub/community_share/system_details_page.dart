import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:solar_hub/layouts/widgets/post_card.dart';
import 'package:solar_hub/layouts/widgets/system_page_info_card_widget.dart';

class SystemDetailsPage extends StatelessWidget {
  const SystemDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> systemData = Get.arguments;
    // print(systemData);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar منزلقة
          SliverAppBar(
            pinned: true,
            expandedHeight: 220.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(systemData['userName'] ?? 'User'),
              background: Image.asset(
                'assets/png/cards/system.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // التفاصيل
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      infoRow('Date', systemData['installDate']),
                      if (systemData['installer'] != null &&
                          systemData['installer'].toString().isNotEmpty)
                        infoRow('Installer', systemData['installer']),
                    ],
                  ),
                  systemInfoCard(
                    context,
                    title: 'Panels',
                    image: 'assets/png/cards/panels.png',
                    children: [
                      infoRow('Power', systemData['panelPower']),
                      // infoRow('Type', systemData['panelType']),
                      infoRow('Count', systemData['panelCount']),
                      infoRow('Brand', systemData['panelBrand']),
                      optionalNote(systemData['panelNotes']),
                    ],
                  ),
                  systemInfoCard(
                    context,
                    title: 'battery',
                    image: 'assets/png/cards/battery.png',
                    children: [
                      infoRow('Voltage', systemData['batteryVoltage']),
                      infoRow('Capacity (Ah)', systemData['batteryAh']),
                      infoRow('Count', systemData['batteryCount']),
                      infoRow('Brand', systemData['batteryBrand']),
                      optionalNote(systemData['batteryNotes']),
                    ],
                  ),
                  systemInfoCard(
                    context,
                    title: 'Inverter',
                    image: 'assets/png/cards/inverter.png',
                    children: [
                      infoRow('Size (kW)', systemData['inverterSize']),
                      infoRow('Type', systemData['inverterType']),
                      infoRow('Brand', systemData['inverterBrand']),
                      optionalNote(systemData['inverterNotes']),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: const Divider(height: 32)),
                      const SizedBox(width: 4),
                      const SizedBox(width: 4),
                      Text(
                        '${systemData['relatedPosts'].length} Posts',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          //  fontSize: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // التعليقات أو المنشورات
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final post = systemData['relatedPosts'][index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: postCard(post),
              );
            }, childCount: systemData['relatedPosts'].length),
          ),
        ],
      ),
    );
  }
}

// Widget _postCard(Map<String, dynamic> post) {
//   return Card(
//     margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//     child: Padding(
//       padding: const EdgeInsets.all(12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(post['title'],
//               style:
//                   const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 6),
//           Text(post['content']),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Icon(Icons.thumb_up, size: 20),
//               SizedBox(width: 4),
//               Text('${post['likes']}'),
//               SizedBox(width: 16),
//               Icon(Icons.thumb_down, size: 20),
//               SizedBox(width: 4),
//               Text('${post['dislikes']}'),
//               Spacer(),
//               Icon(Icons.comment, size: 20),
//               SizedBox(width: 4),
//               Text('${post['comments'].length} comments'),
//             ],
//           ),
//         ],
//       ),
//     ),
//   );
// }
//  Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _sectionTitle('Solar Panels'),
//         infoRow('Power', systemData['panelPower']),
//         // infoRow('Type', systemData['panelType']),
//         infoRow('Count', systemData['panelCount']),
//         infoRow('Brand', systemData['panelBrand']),
//         optionalNote(systemData['panelNotes']),
//         _sectionTitle('Battery'),
//         infoRow('Voltage', systemData['batteryVoltage']),
//         infoRow('Capacity (Ah)', systemData['batteryAh']),
//         infoRow('Count', systemData['batteryCount']),
//         infoRow('Brand', systemData['batteryBrand']),
//         optionalNote(systemData['batteryNotes']),
//         _sectionTitle('Inverter'),
//         infoRow('Size (kW)', systemData['inverterSize']),
//         infoRow('Type', systemData['inverterType']),
//         infoRow('Brand', systemData['inverterBrand']),
//         optionalNote(systemData['inverterNotes']),
//         _sectionTitle('Install Info'),
//         _
//       ],
//     ),
