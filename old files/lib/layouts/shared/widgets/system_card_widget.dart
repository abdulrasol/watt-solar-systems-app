import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/features/systems/models/system_model.dart';

Widget systemCard(BuildContext context, SystemModel system) {
  final isDark = Get.isDarkMode;
  final cardColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
  final primaryColor = Theme.of(context).primaryColor;

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
    ),
    child: InkWell(
      onTap: () {
        Get.toNamed('/community/system', arguments: system);
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: primaryColor.withValues(alpha: 0.1),
                  child: Icon(Iconsax.flash_1_bold, color: primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(system.userName ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(system.installedAt?.toString().substring(0, 10) ?? 'Unknown Date', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Iconsax.arrow_right_3_outline, size: 20),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),

          // Stats Grid
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(context, Iconsax.sun_1_bold, "Solar", "${(system.pv.count * system.pv.capacity) / 1000} kWp", Colors.orange),
                _buildStatItem(context, Iconsax.electricity_bold, "Inverter", "${system.inverter.capacity} kVA", Colors.blue),
                _buildStatItem(
                  context,
                  Iconsax.battery_charging_bold,
                  "Battery",
                  "${system.battery.count * system.battery.capacity} unt", // Simplified as we don't have voltage in new model explicitly unless in details
                  Colors.green,
                ),
              ],
            ),
          ),

          if (system.companyName != null && system.companyName!.isNotEmpty) ...[
            Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.verify_bold, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    "Installed by ${system.companyName}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

Widget _buildStatItem(BuildContext context, IconData icon, String label, String value, Color color) {
  return Expanded(
    child: Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
