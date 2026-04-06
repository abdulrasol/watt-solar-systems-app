import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class CompanyStatusForm extends StatefulWidget {
  final String currentStatus;
  final Function(String status) onSubmit;

  const CompanyStatusForm({
    super.key,
    required this.currentStatus,
    required this.onSubmit,
  });

  @override
  State<CompanyStatusForm> createState() => _CompanyStatusFormState();
}

class _CompanyStatusFormState extends State<CompanyStatusForm> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.currentStatus.toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Update Company Status',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Iconsax.close_circle_bold,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatusOption(
              'pending',
              'Pending Review',
              Iconsax.clock_bold,
              AppTheme.warningColor,
            ),
            const SizedBox(height: 12),
            _buildStatusOption(
              'active',
              'Activate Company',
              Iconsax.tick_circle_bold,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildStatusOption(
              'rejected',
              'Reject Company',
              Iconsax.close_circle_bold,
              AppTheme.errorColor,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSubmit(_status);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'UPDATE STATUS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(
    String status,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _status == status;
    return InkWell(
      onTap: () => setState(() => _status = status),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 24),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Iconsax.tick_circle_bold, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}
