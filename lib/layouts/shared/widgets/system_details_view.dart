import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_hub/models/system_model.dart';
import 'package:solar_hub/layouts/shared/widgets/system_page_info_card_widget.dart';

class SystemDetailsView extends StatelessWidget {
  final SystemModel system;

  const SystemDetailsView({super.key, required this.system});

  @override
  Widget build(BuildContext context) {
    // Helper to safely access nested maps
    final panels = system.specs['panels'] as Map<String, dynamic>?;
    final battery = system.specs['battery'] as Map<String, dynamic>? ?? system.specs['batteries'] as Map<String, dynamic>?;
    final inverter = system.specs['inverter'] as Map<String, dynamic>? ?? system.specs['inverters'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Stats
        Row(
          children: [
            Expanded(child: _statCard("total_capacity".tr, "${system.totalCapacityKw?.toStringAsFixed(2) ?? '0'} kW", Icons.bolt, Colors.orange)),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                "created_date".tr,
                system.createdAt != null ? "${system.createdAt!.day}/${system.createdAt!.month}/${system.createdAt!.year}" : "-",
                Icons.calendar_today,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Panels Section
        if (panels != null)
          systemInfoCard(
            context,
            title: 'Panels',
            image: 'assets/png/cards/panels.png',
            children: [
              infoRow('Total Power', "${(_toDouble(panels['capacity']) * _toInt(panels['count'])) / 1000} kW"),
              infoRow('Panel Wattage', "${panels['capacity']} W"),
              infoRow('Count', "${panels['count']}"),
              if (panels['note'] != null && panels['note'].toString().isNotEmpty) infoRow('Note', "${panels['note']}"),
            ],
          ),

        // Batteries Section
        if (battery != null)
          systemInfoCard(
            context,
            title: 'Batteries',
            image: 'assets/png/cards/battery.png',
            children: [
              infoRow('Capacity', "${battery['capacity']} ${battery['voltage_type'] == 'HV' ? 'kW' : 'Ah'}"),
              infoRow('Count', "${battery['count']} ${battery['voltage_type'] == 'HV' ? 'Bank' : ''}"),
              infoRow('Type', "${battery['type']}"),
              infoRow('Voltage Type', "${battery['voltage_type']}"),
              if (battery['system_voltage'] != null) infoRow('System Voltage', "${battery['system_voltage']} V"),
              if (battery['note'] != null && battery['note'].toString().isNotEmpty) infoRow('Note', "${battery['note']}"),
            ],
          ),

        // Inverter Section
        if (inverter != null)
          systemInfoCard(
            context,
            title: 'Inverter',
            image: 'assets/png/cards/inverter.png',
            children: [
              infoRow('Capacity', "${inverter['capacity']} kW"),
              infoRow('Count', "${inverter['count']}"),
              infoRow('Type', "${inverter['type']}"),
              infoRow('Phase', "${inverter['phase']}"),
              infoRow('Voltage Type', "${inverter['voltage_type']}"),
              if (inverter['note'] != null && inverter['note'].toString().isNotEmpty) infoRow('Note', "${inverter['note']}"),
            ],
          ),

        // Instructions / Notes
        if (system.notes != null && system.notes!.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text("Notes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Text(system.notes!),
          ),
        ],
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // Helpers to handle potential String vs num types in JSON
  double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }
}
