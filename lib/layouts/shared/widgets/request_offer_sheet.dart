import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/controllers/systems_controller.dart';
import 'package:solar_hub/models/system_model.dart';
import 'package:solar_hub/utils/app_theme.dart';

class RequestOfferSheet extends StatefulWidget {
  final SystemModel system;

  const RequestOfferSheet({super.key, required this.system});

  @override
  State<RequestOfferSheet> createState() => _RequestOfferSheetState();
}

class _RequestOfferSheetState extends State<RequestOfferSheet> {
  final TextEditingController _notesController = TextEditingController();
  final SystemsController _controller = Get.find();

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing notes if any
    if (widget.system.notes != null) {
      _notesController.text = widget.system.notes!;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Iconsax.export_bold, color: AppTheme.primaryColor),
              const SizedBox(width: 10),
              Text("Request Offer", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),
          Text("System: ${widget.system.systemName}", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("Sending details for: ${_getSummary(widget.system)}", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          const Text("Add Notes for Companies (Optional)"),
          const SizedBox(height: 8),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "E.g., Preferred brand, installation location details...",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _controller.requestOffers(widget.system, notes: _notesController.text.trim());
                Get.back(); // Close sheet
              },
              icon: const Icon(Iconsax.send_2_bold),
              label: const Text("Submit Request"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSummary(SystemModel system) {
    List<String> parts = [];
    final specs = system.specs;
    // Safe parsing logic
    final panels = specs['panels'] is List ? specs['panels'] as List : (specs['panels'] != null ? [specs['panels']] : []);
    final batteries = specs['batteries'] is List ? specs['batteries'] as List : (specs['batteries'] != null ? [specs['batteries']] : []);
    final inverters = specs['inverters'] is List ? specs['inverters'] as List : (specs['inverters'] != null ? [specs['inverters']] : []);

    if (panels.isNotEmpty) parts.add("${panels.length} Panel Set(s)");
    if (batteries.isNotEmpty) parts.add("${batteries.length} Battery Bank(s)");
    if (inverters.isNotEmpty) parts.add("${inverters.length} Inverter(s)");
    if (specs['wires'] != null) parts.add("Wiring");

    if (parts.isEmpty) return "Full System Design";
    return parts.join(", ");
  }
}
