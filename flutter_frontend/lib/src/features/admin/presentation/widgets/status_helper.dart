import 'package:flutter/material.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

/// Helper class for handling status colors and labels across the app
class StatusHelper {
  /// Get color for a given status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'rejected':
      case 'cancelled':
        return AppTheme.errorColor;
      case 'suspended':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Get display label for status
  static String getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Active';
      case 'pending':
        return 'Pending';
      case 'rejected':
        return 'Rejected';
      case 'suspended':
        return 'Suspended';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  /// Get icon for a given status
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.schedule_outlined;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'suspended':
        return Icons.pause_circle_outline;
      case 'cancelled':
        return Icons.block_outlined;
      default:
        return Icons.help_outline;
    }
  }
}
