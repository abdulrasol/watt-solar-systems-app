// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:solar_hub/controllers/data_controller.dart';
// import 'package:solar_hub/utils/app_constants.dart';

// final DataController dataContrller = Get.find();

// class UserSystem extends StatelessWidget {
//   late final String userName;
//   late final int panelCount;
//   late final int panelWatt;
//   late final String panelBrand;
//   late final double inverterCapacity;
//   late final String inverterBrand;
//   late final String inverterType;
//   late final double batteryCapacity;
//   late final String batteryBrand;
//   late final String batteryType;
//   late final String address;

//   UserSystem({
//     super.key,
//   }) {
//     userName = dataContrller.userSystem.value['username'];

//     address = dataContrller.userSystem.value['address']['address'];

//     panelCount = dataContrller.userSystem.value['panel']['count'];
//     panelWatt = dataContrller.userSystem.value['panel']['power'];
//     panelBrand = dataContrller.userSystem.value['panel']['brand'];

//     inverterType = dataContrller.userSystem.value['inverter']['type'];
//     inverterCapacity =
//         dataContrller.userSystem.value['inverter']['power'].toDouble();
//     inverterBrand = dataContrller.userSystem.value['inverter']['brand'];

//     batteryType = dataContrller.userSystem.value['battery']['type'];
//     batteryCapacity =
//         dataContrller.userSystem.value['battery']['power'].toDouble();
//     batteryBrand = dataContrller.userSystem.value['battery']['brand'];
//   }
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("تفاصيل منظومة $userName"),
//         centerTitle: true,
//         actions: [
//           TextButton.icon(
//               onPressed: () {
//                 Get.toNamed('/user-system-input');
//               },
//               label: Text('Edit My System'))
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             _buildSectionTitle(
//               context,
//               "تفاصيل الألواح",
//               "assets/png/cards/panels.png",
//             ),
//             _buildInfoCard(
//               //  imagePath: "assets/png/cards/panels.png",
//               children: [
//                 _buildRow("عدد الألواح", "$panelCount"),
//                 _buildRow("قدرة اللوح", "$panelWatt واط"),
//                 _buildRow("ماركة الألواح", panelBrand),
//               ],
//             ),
//             const SizedBox(height: 16),
//             _buildSectionTitle(
//                 context, "تفاصيل الإنفرتر", "assets/png/cards/inverter.png"),
//             _buildInfoCard(
//               //  imagePath: "assets/png/cards/inverter.png",
//               children: [
//                 _buildRow("قدرة الإنفرتر", "$inverterCapacity كيلو واط"),
//                 _buildRow("ماركة الإنفرتر", inverterBrand),
//                 _buildRow("نوع الإنفرتر", inverterType),
//               ],
//             ),
//             const SizedBox(height: 16),
//             _buildSectionTitle(
//                 context, "تفاصيل البطارية", "assets/png/cards/battery.png"),
//             _buildInfoCard(
//               //  imagePath: "assets/png/cards/battery.png",
//               children: [
//                 _buildRow("سعة البطارية", "$batteryCapacity كيلو واط"),
//                 _buildRow("ماركة البطارية", batteryBrand),
//                 _buildRow("نوع البطارية", batteryType),
//               ],
//             ),
//             const SizedBox(height: 16),
//             _buildSectionTitle(context, "معلومات الموقع", null),
//             _buildInfoCard(
//               children: [
//                 _buildRow("العنوان", address),
//                 _buildRow("إحداثيات GPS", "🌍 (سيُضاف لاحقًا)"),
//               ],
//             ),
//             const SizedBox(height: 30),
//             _buildSectionTitle(context, "مشاركات أو تعليقات", null),
//             verSpace(),
//             Card(
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               elevation: 3,
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Center(
//                   child: Text(
//                     "لا توجد تعليقات بعد 📝\n(سيتم تفعيل هذه الميزة قريبًا)",
//                     style: theme.textTheme.bodyMedium
//                         ?.copyWith(color: theme.hintColor),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(
//       BuildContext context, String title, String? imagePath) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             title,
//             style: Theme.of(context)
//                 .textTheme
//                 .titleLarge
//                 ?.copyWith(fontWeight: FontWeight.bold),
//           ),
//         ),
//         if (imagePath != null)
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
//             child: Image.asset(
//               imagePath,
//               height: 40,
//               fit: BoxFit.contain,
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildInfoCard({required List<Widget> children}) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Expanded(
//               child: Text(label,
//                   style: const TextStyle(fontWeight: FontWeight.w600))),
//           Text(value),
//         ],
//       ),
//     );
//   }
// }
