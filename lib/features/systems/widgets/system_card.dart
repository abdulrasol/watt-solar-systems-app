import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/systems/models/system_model.dart';

import 'package:timeago/timeago.dart' as timeago;

class SystemCard extends StatelessWidget {
  final SystemModel system;
  final VoidCallback? onTap;
  final bool showStatus;

  const SystemCard({super.key, required this.system, this.onTap, this.showStatus = true});

  @override
  Widget build(BuildContext context) {
    // Total Capacity Calc (Approx)
    double totalKw = (system.pv.count * system.pv.capacity) / 1000;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Iconsax.sun_1_bold, color: Colors.orange, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${totalKw.toStringAsFixed(1)} kW System", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(system.city ?? 'Unknown Location', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                ),
                if (system.installedAt != null) Text(timeago.format(system.installedAt!), style: TextStyle(color: Colors.grey[400], fontSize: 11)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoBadge(Iconsax.flash_bold, "${system.pv.count} Panels", Colors.blue),
                _buildInfoBadge(Iconsax.battery_charging_bold, "${system.battery.count} Batts", Colors.green),
                _buildInfoBadge(Iconsax.electricity_bold, "${system.inverter.capacity} kVA", Colors.red),
              ],
            ),
            if (showStatus) ...[
              const SizedBox(height: 12),
              Row(children: [_buildStatusChip("User", system.userStatus), const SizedBox(width: 8), _buildStatusChip("Company", system.companyStatus)]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildStatusChip(String label, String status) {
    Color color = Colors.grey;
    if (status == 'accepted') color = Colors.green;
    if (status == 'rejected') color = Colors.red;
    if (status == 'pending') color = Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        "$label: ${status.capitalizeFirst}",
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
