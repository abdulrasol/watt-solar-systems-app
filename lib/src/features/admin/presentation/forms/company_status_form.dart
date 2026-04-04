import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class CompanyStatusForm extends StatefulWidget {
  final String currentStatus;
  final Function(String status) onSubmit;

  const CompanyStatusForm({super.key, required this.currentStatus, required this.onSubmit});

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
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Update Company Status',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Iconsax.close_circle_bold, color: Colors.grey, size: 24.sp),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildStatusOption('pending', 'Pending Review', Iconsax.clock_bold, AppTheme.warningColor),
          SizedBox(height: 12.h),
          _buildStatusOption('active', 'Activate Company', Iconsax.tick_circle_bold, Colors.green),
          SizedBox(height: 12.h),
          _buildStatusOption('rejected', 'Reject Company', Iconsax.close_circle_bold, AppTheme.errorColor),
          SizedBox(height: 24.h),
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
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(
                'UPDATE STATUS',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildStatusOption(String status, String label, IconData icon, Color color) {
    final isSelected = _status == status;
    return InkWell(
      onTap: () => setState(() => _status = status),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: isSelected ? color : Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 24.sp),
            SizedBox(width: 16.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            const Spacer(),
            if (isSelected) Icon(Iconsax.tick_circle_bold, color: color, size: 24.sp),
          ],
        ),
      ),
    );
  }
}
