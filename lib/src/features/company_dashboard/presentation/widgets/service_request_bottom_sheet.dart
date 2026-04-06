import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/widgets/loading_widgets.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/repositories/company_service_request_repository.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class ServiceRequestBottomSheet extends StatefulWidget {
  final int companyId;
  final String serviceCode;
  final String serviceName;
  final VoidCallback onSuccess;

  const ServiceRequestBottomSheet({super.key, required this.companyId, required this.serviceCode, required this.serviceName, required this.onSuccess});

  @override
  State<ServiceRequestBottomSheet> createState() => _ServiceRequestBottomSheetState();
}

class _ServiceRequestBottomSheetState extends State<ServiceRequestBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  File? _image;
  bool _isSubmitting = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  void _showImageSourceDialog() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Iconsax.image_bold, color: AppTheme.primaryColor),
              title: Text(l10n.gallery, style: TextStyle(fontFamily: AppTheme.fontFamily)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Iconsax.camera_bold, color: AppTheme.primaryColor),
              title: Text(l10n.camera, style: TextStyle(fontFamily: AppTheme.fontFamily)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final repository = getIt<CompanyServiceRequestRepository>();
      MultipartFile? multipartFile;

      if (_image != null) {
        multipartFile = await MultipartFile.fromFile(_image!.path, filename: _image!.path.split('/').last);
      }

      await repository.createServiceRequest(
        companyId: widget.companyId,
        serviceCode: widget.serviceCode,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        imageFile: multipartFile,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.request_submitted_success), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating));
        widget.onSuccess();
        Navigator.pop(context);
      }
    } catch (e, s) {
      dPrint(e, stackTrace: s);
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.request_failed}: $e'), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.only(left: 24.w, top: 24.h, right: 24.w, bottom: MediaQuery.of(context).viewInsets.bottom + 24.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.request_service,
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.serviceName,
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Iconsax.close_circle_bold, color: Colors.grey, size: 24.sp),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                l10n.request_notes_hint,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, fontFamily: AppTheme.fontFamily),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: AppTheme.inputDecoration(l10n.request_notes, l10n.request_notes_hint_text).copyWith(contentPadding: EdgeInsets.all(16.w)),
                style: TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 14.sp),
              ),
              SizedBox(height: 24.h),
              Text(
                l10n.request_image,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, fontFamily: AppTheme.fontFamily),
              ),
              SizedBox(height: 8.h),
              InkWell(
                onTap: _showImageSourceDialog,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  height: 150.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: _image != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: InkWell(
                                onTap: () => setState(() => _image = null),
                                child: Container(
                                  padding: EdgeInsets.all(6.w),
                                  decoration: BoxDecoration(color: AppTheme.errorColor, shape: BoxShape.circle),
                                  child: Icon(Iconsax.close_circle_bold, color: Colors.white, size: 16.sp),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.image_bold, size: 40.sp, color: Colors.grey),
                            SizedBox(height: 8.h),
                            Text(
                              l10n.tap_to_select_image,
                              style: TextStyle(fontSize: 13.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: _isSubmitting
                      ? LoadingWidget.widget(context: context, size: 20)
                      : Text(
                          l10n.submit_request,
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
