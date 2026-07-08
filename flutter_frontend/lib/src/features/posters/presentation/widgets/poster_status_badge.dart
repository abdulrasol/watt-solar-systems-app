import 'package:flutter/material.dart';
import 'package:solar_hub/src/features/posters/domain/entities/poster_entity.dart';

class PosterStatusBadge extends StatelessWidget {
  final PosterEntity poster;

  const PosterStatusBadge({super.key, required this.poster});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (poster.status) {
      'approved' => (const Color(0xFF10B981), 'Approved'),
      'pending' => (Colors.orange, 'Pending'),
      'rejected' => (Colors.red, 'Rejected'),
      _ => (Colors.grey, poster.status),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
