import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/features/systems/controllers/systems_controller.dart';
import 'package:solar_hub/features/auth/controllers/auth_controller.dart';
import 'package:solar_hub/features/systems/widgets/system_card.dart';
import 'package:solar_hub/features/systems/screens/system_form_page.dart';
import 'package:solar_hub/features/systems/screens/system_details_page.dart';
import 'package:solar_hub/utils/toast_service.dart';

class MySystemsPage extends StatefulWidget {
  const MySystemsPage({super.key});

  @override
  State<MySystemsPage> createState() => _MySystemsPageState();
}

class _MySystemsPageState extends State<MySystemsPage> {
  final _controller = Get.put(SystemsController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.fetchUserSystems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Systems")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Get.to(() => const SystemFormPage(isUserView: true));
          if (res == true) ToastService.success("Success", "System saved successfully");
        },
        label: const Text("Add System"),
        icon: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.mySystems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.solar_power, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text("No systems added yet", style: TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () async {
                    final res = await Get.to(() => const SystemFormPage(isUserView: true));
                    if (res == true) ToastService.success("Success", "System saved successfully");
                  },
                  child: const Text("Add your first system"),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.fetchUserSystems,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _controller.mySystems.length + 1,
            itemBuilder: (context, index) {
              if (index == _controller.mySystems.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text(
                      "Linked Phone: ${Get.find<AuthController>().user.value?.phone ?? 'Unknown'}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                );
              }
              final system = _controller.mySystems[index];
              return SystemCard(
                system: system,
                onTap: () => Get.to(() => SystemDetailsPage(system: system)),
              );
            },
          ),
        );
      }),
    );
  }
}
