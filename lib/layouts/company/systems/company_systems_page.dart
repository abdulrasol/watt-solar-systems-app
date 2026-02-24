import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/systems/controllers/systems_controller.dart';
import 'package:solar_hub/features/systems/widgets/system_card.dart';
import 'package:solar_hub/features/systems/screens/system_form_page.dart';
import 'package:solar_hub/features/systems/screens/system_details_page.dart';

class CompanySystemsPage extends StatefulWidget {
  final String companyId;
  const CompanySystemsPage({super.key, required this.companyId});

  @override
  State<CompanySystemsPage> createState() => _CompanySystemsPageState();
}

class _CompanySystemsPageState extends State<CompanySystemsPage> {
  final _controller = Get.put(SystemsController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchCompanySystems(widget.companyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Company Systems")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => SystemFormPage(isUserView: false, companyId: widget.companyId)),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_controller.companySystems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.box_bold, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                const Text("No installations found.", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }
        // Filter? "only related system ... when installed_by is equal uuid of this company" -> already filtered by fetchCompanySystems(companyId)
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _controller.companySystems.length,
          itemBuilder: (context, index) {
            final system = _controller.companySystems[index];
            return SystemCard(
              system: system,
              onTap: () {
                Get.to(() => SystemDetailsPage(system: system, isCompanyView: true));
              },
            );
          },
        );
      }),
    );
  }
}
