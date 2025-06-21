// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:solar_hub/controllers/data_controller.dart';
// import 'package:validatorless/validatorless.dart';

// final DataController dataContrller = Get.find();

// class UserSystemInput extends StatefulWidget {
//   const UserSystemInput({super.key});
//   @override
//   UserSystemInputState createState() => UserSystemInputState();
// }

// class UserSystemInputState extends State<UserSystemInput> {
//   final _formKey = GlobalKey<FormState>();

//   final userNameController =
//       TextEditingController(text: dataContrller.userSystem.value['username']);
//   final panelCountController = TextEditingController(
//       text: dataContrller.userSystem.value['panel']['count'].toString());
//   final panelWattController = TextEditingController(
//       text: dataContrller.userSystem.value['panel']['power'].toString());
//   final panelBrandController = TextEditingController(
//       text: dataContrller.userSystem.value['panel']['brand']);
//   final inverterCapacityController = TextEditingController(
//       text: dataContrller.userSystem.value['inverter']['power'].toString());
//   final inverterBrandController = TextEditingController(
//       text: dataContrller.userSystem.value['inverter']['brand']);
//   final batteryCapacityController = TextEditingController(
//       text: dataContrller.userSystem.value['battery']['power'].toString());
//   final batteryBrandController = TextEditingController(
//       text: dataContrller.userSystem.value['battery']['brand'].toString());
//   final addressController = TextEditingController(
//       text: dataContrller.userSystem.value['address']['address']);

//   String inverterType = dataContrller.userSystem.value['inverter']['type'];
//   String batteryType = dataContrller.userSystem.value['battery']['type'];

//   @override
//   void dispose() {
//     userNameController.dispose();
//     panelCountController.dispose();
//     panelWattController.dispose();
//     panelBrandController.dispose();
//     inverterCapacityController.dispose();
//     inverterBrandController.dispose();
//     batteryCapacityController.dispose();
//     batteryBrandController.dispose();
//     addressController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("منظومتي الشمسية"),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Card(
//           elevation: 5,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Text("معلومات المستخدم", style: theme.textTheme.titleMedium),
//                   const SizedBox(height: 10),
//                   _buildTextField(
//                     userNameController,
//                     "اسم المستخدم",
//                     Validatorless.multiple([
//                       Validatorless.required('Required'),
//                     ]),
//                   ),
//                   const SizedBox(height: 20),
//                   Text("تفاصيل الألواح", style: theme.textTheme.titleMedium),
//                   const SizedBox(height: 10),
//                   _buildTextField(
//                       panelCountController,
//                       "عدد الألواح",
//                       Validatorless.multiple([
//                         Validatorless.required('Required'),
//                         Validatorless.number('Numbers only'),
//                       ]),
//                       TextInputType.number),
//                   _buildTextField(
//                       panelWattController,
//                       "قدرة اللوح (واط)",
//                       Validatorless.multiple([
//                         Validatorless.required('Required'),
//                         Validatorless.number('Numbers only'),
//                       ]),
//                       TextInputType.number),
//                   _buildTextField(
//                     panelBrandController,
//                     "ماركة الألواح",
//                     Validatorless.multiple([
//                       Validatorless.required('Required'),
//                     ]),
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     "تفاصيل الإنفرتر",
//                     style: theme.textTheme.titleMedium,
//                   ),
//                   const SizedBox(height: 10),
//                   _buildTextField(
//                       inverterCapacityController,
//                       "قدرة الإنفرتر (كيلو واط)",
//                       Validatorless.multiple([
//                         Validatorless.required('Required'),
//                         Validatorless.number('Numbers only'),
//                       ]),
//                       TextInputType.number),
//                   _buildTextField(
//                     inverterBrandController,
//                     "ماركة الإنفرتر",
//                     Validatorless.multiple([
//                       Validatorless.required('Required'),
//                     ]),
//                   ),
//                   DropdownButtonFormField<String>(
//                     value: inverterType,
//                     decoration: InputDecoration(labelText: "نوع الإنفرتر"),
//                     items: ['On-Grid', 'Off-Grid', 'Hybrid']
//                         .map((type) => DropdownMenuItem(
//                               value: type,
//                               child: Text(type),
//                             ))
//                         .toList(),
//                     onChanged: (value) {
//                       if (value != null) {
//                         setState(() {
//                           inverterType = value;
//                         });
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   Text("تفاصيل البطارية", style: theme.textTheme.titleMedium),
//                   const SizedBox(height: 10),
//                   _buildTextField(
//                       batteryCapacityController,
//                       "سعة البطارية (كيلو واط)",
//                       Validatorless.multiple([
//                         Validatorless.required('Required'),
//                         Validatorless.number('Numbers only'),
//                       ]),
//                       TextInputType.number),
//                   _buildTextField(
//                     batteryBrandController,
//                     "ماركة البطارية",
//                     Validatorless.multiple([
//                       Validatorless.required('Required'),
//                     ]),
//                   ),
//                   DropdownButtonFormField<String>(
//                     value: batteryType,
//                     decoration: InputDecoration(labelText: "نوع البطارية"),
//                     items: ['Lithium', 'Lead Acid']
//                         .map((type) => DropdownMenuItem(
//                               value: type,
//                               child: Text(type),
//                             ))
//                         .toList(),
//                     onChanged: (value) {
//                       if (value != null) {
//                         setState(() {
//                           batteryType = value;
//                         });
//                       }
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   Text("معلومات الموقع", style: theme.textTheme.titleMedium),
//                   const SizedBox(height: 10),
//                   _buildTextField(
//                     addressController,
//                     "العنوان",
//                     Validatorless.multiple([
//                       Validatorless.required('Required'),
//                     ]),
//                   ),
//                   const SizedBox(height: 10),
//                   ElevatedButton.icon(
//                     icon: Icon(Icons.location_on),
//                     label: Text("تحديد الموقع من GPS"),
//                     onPressed: () {
//                       // تضيف GPS لاحقًا
//                     },
//                   ),
//                   const SizedBox(height: 30),
//                   ElevatedButton(
//                     onPressed: () {
//                       if (_formKey.currentState!.validate()) {
//                         final data = {
//                           'username': userNameController.text,
//                           'address': {
//                             'address': addressController.text,
//                             'lan': '',
//                             'lag': '',
//                           },
//                           'panel': {
//                             'count': num.parse(panelCountController.text),
//                             'power': num.parse(panelWattController.text),
//                             'brand': panelBrandController.text,
//                             'details': '',
//                           },
//                           'inverter': {
//                             'power': num.parse(inverterCapacityController.text),
//                             'brand': inverterBrandController.text,
//                             'type': inverterType,
//                             'details': ''
//                           },
//                           'battery': {
//                             'power': num.parse(batteryCapacityController.text),
//                             'count': 1,
//                             'brand': batteryBrandController.text,
//                             'type': batteryType,
//                             'details': ''
//                           },
//                         };
//                         dataContrller.updateUserSystem(data);
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text("تم حفظ بيانات المنظومة ✅")),
//                         );
//                       }
//                     },
//                     child: Text("حفظ المنظومة"),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//       TextEditingController controller, String label, validator,
//       [TextInputType inputType = TextInputType.text]) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: inputType,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//         ),
//         validator: validator,
//       ),
//     );
//   }
// }
