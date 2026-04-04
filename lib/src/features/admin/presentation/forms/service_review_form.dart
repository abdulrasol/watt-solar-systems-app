import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/src/features/admin/domain/models/service_request.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class ServiceReviewForm extends StatefulWidget {
  final ServiceRequest request;
  final Function(Map<String, dynamic> data) onSubmit;

  const ServiceReviewForm({super.key, required this.request, required this.onSubmit});

  @override
  State<ServiceReviewForm> createState() => _ServiceReviewFormState();
}

class _ServiceReviewFormState extends State<ServiceReviewForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _notesController;
  late DateTime _startDate;
  late DateTime _endDate;
  late String _status;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.request.notes ?? '');
    _startDate = DateTime.now();
    _endDate = DateTime.now().add(const Duration(days: 365));
    _status = 'active';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 24.h),
              _buildStatusSelector(),
              SizedBox(height: 24.h),
              if (_status == 'active') ...[
                _buildDatePicker('Start Date', _startDate, (date) => setState(() => _startDate = date)),
                SizedBox(height: 16.h),
                _buildDatePicker('End Date', _endDate, (date) => setState(() => _endDate = date)),
                SizedBox(height: 16.h),
              ],
              _buildTextField('Review Notes', _notesController, maxLines: 3),
              SizedBox(height: 24.h),
              _buildSubmitButton(),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Review Service Request',
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
        Text(
          '${widget.request.companyName} - ${widget.request.serviceName}',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Row(
      children: [
        _buildStatusButton('active', 'Approve', Colors.green),
        SizedBox(width: 12.w),
        _buildStatusButton('rejected', 'Reject', AppTheme.errorColor),
        SizedBox(width: 12.w),
        _buildStatusButton('pending', 'Pending', AppTheme.warningColor),
      ],
    );
  }

  Widget _buildStatusButton(String status, String label, Color color) {
    final isSelected = _status == status;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _status = status),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: isSelected ? color : Colors.grey.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(
                isSelected ? Iconsax.tick_circle_bold : Iconsax.record_circle_bold,
                color: isSelected ? color : Colors.grey,
                size: 20.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.grey,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime current, Function(DateTime) onSelected) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: current,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (date != null) onSelected(date);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 10.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily)),
                Text(
                  '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
                ),
              ],
            ),
            const Spacer(),
            Icon(Iconsax.calendar_bold, color: AppTheme.primaryColor, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14.sp),
      decoration: AppTheme.inputDecoration(label, label),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final data = {
            'status': _status,
            'notes': _notesController.text,
            'starts_at': _startDate.toIso8601String(),
            'ends_at': _endDate.toIso8601String(),
          };
          widget.onSubmit(data);
          Navigator.pop(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
        child: Text(
          'UPDATE SUBSCRIPTION',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      ),
    );
  }
}
