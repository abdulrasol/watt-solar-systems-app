import 'package:flutter/material.dart';
import 'package:solar_hub/layouts/shared/widgets/system_page_info_card_widget.dart';
import 'package:solar_hub/utils/app_theme.dart';

class OfferDetailsView extends StatelessWidget {
  final Map<String, dynamic> offer;

  const OfferDetailsView({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final pv = offer['pv_specs'] as Map<String, dynamic>?;
    final battery = offer['battery_specs'] as Map<String, dynamic>?;
    final inverter = offer['inverter_specs'] as Map<String, dynamic>?;
    final involves = offer['involves'] as List?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (pv != null && (pv['count'] != null || pv['capacity'] != null))
          _buildSpecSection(
            context,
            title: 'PV Panels',
            icon: Icons.wb_sunny,
            color: Colors.amber,
            children: [
              if (pv['count'] != null) infoRow('Count', "${pv['count']}"),
              if (pv['capacity'] != null) infoRow('Capacity', "${pv['capacity']} W"),
              if (pv['mark'] != null) infoRow('Mark', "${pv['mark']}"),
            ],
          ),

        if (battery != null && (battery['count'] != null || battery['capacity'] != null))
          _buildSpecSection(
            context,
            title: 'Batteries',
            icon: Icons.battery_charging_full,
            color: Colors.green,
            children: [
              if (battery['count'] != null) infoRow('Count', "${battery['count']}"),
              if (battery['capacity'] != null)
                infoRow('Capacity', "${battery['capacity']} ${battery['capacity'] > 100 ? 'Ah' : 'kW'}"), // Heuristic or explicit unit
              if (battery['mark'] != null) infoRow('Mark', "${battery['mark']}"),
            ],
          ),

        if (inverter != null && (inverter['count'] != null || inverter['capacity'] != null))
          _buildSpecSection(
            context,
            title: 'Inverter',
            icon: Icons.flash_on,
            color: Colors.redAccent,
            children: [
              if (inverter['count'] != null) infoRow('Count', "${inverter['count']}"),
              if (inverter['capacity'] != null) infoRow('Capacity', "${inverter['capacity']} kW"),
              if (inverter['mark'] != null) infoRow('Mark', "${inverter['mark']}"),
              if (inverter['phase'] != null) infoRow('Phase', "${inverter['phase']}"),
            ],
          ),

        if (involves != null && involves.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text("Includes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: involves
                .map(
                  (e) => Chip(
                    label: Text(e.toString()),
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    labelStyle: TextStyle(color: AppTheme.primaryColor, fontSize: 12),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSpecSection(BuildContext context, {required String title, required IconData icon, required Color color, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }
}
