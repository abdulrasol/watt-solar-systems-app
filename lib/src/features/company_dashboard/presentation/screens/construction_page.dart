import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/core/widgets/wd_image_preview.dart';
import 'package:solar_hub/src/utils/app_enums.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class ServiceStatusPage extends StatelessWidget {
  final String serviceName;
  final String serviceCode;
  final String? status;
  final String? iconUrl;

  const ServiceStatusPage({super.key, required this.serviceName, required this.serviceCode, this.status, this.iconUrl});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ServiceStatus state = ServiceStatus.fromString(status);
    final bool hasCustomIcon = iconUrl != null && iconUrl!.isNotEmpty && iconUrl != 'null';

    // UI Configuration based on status
    String title;
    String description;
    String subDescription;
    IconData fallbackIcon;
    Color statusColor;
    Widget actionButton;

    if (status == null || status == 'null' || status!.isEmpty) {
      title = l10n.ready_to_scale_title;
      description = l10n.service_not_requested(serviceName);
      subDescription = l10n.service_unlock_description;
      fallbackIcon = Iconsax.add_square_bold;
      statusColor = AppTheme.primaryColor;
      actionButton = ElevatedButton.icon(
        onPressed: () {
          // TODO: Implement Request Access logic
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.access_requested_successfully)));
        },
        icon: const Icon(Iconsax.flash_1_bold),
        label: Text(l10n.request_access_now),
      );
    } else {
      statusColor = state.color;
      fallbackIcon = state.icon;

      switch (state) {
        case ServiceStatus.pending:
          title = l10n.awaiting_approval;
          description = l10n.service_under_review(serviceName);
          subDescription = l10n.service_pending_help;
          actionButton = OutlinedButton.icon(
            onPressed: () => _contactSupport(context),
            icon: const Icon(Iconsax.message_question_bold),
            label: Text(l10n.contact_support),
          );
          break;
        case ServiceStatus.rejected:
          title = l10n.request_denied;
          description = l10n.service_request_rejected(serviceName);
          subDescription = l10n.service_rejected_help;
          actionButton = ElevatedButton.icon(
            onPressed: () => _contactSupport(context),
            icon: const Icon(Iconsax.message_question_bold),
            label: Text(l10n.appeal_decision),
          );
          break;
        case ServiceStatus.suspended:
        case ServiceStatus.cancelled:
          title = l10n.access_limited;
          description = l10n.service_suspended_or_cancelled(serviceName);
          subDescription = l10n.service_accounts_help;
          actionButton = ElevatedButton.icon(
            onPressed: () => _contactSupport(context),
            icon: const Icon(Iconsax.call_calling_bold),
            label: Text(l10n.contact_accounts),
          );
          break;
        default:
          title = l10n.service_maintenance;
          description = l10n.service_being_updated(serviceName);
          subDescription = l10n.service_maintenance_help;
          actionButton = ElevatedButton(onPressed: () => context.pop(), child: Text(l10n.back_to_dashboard));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(serviceName),
        leading: IconButton(icon: const Icon(Iconsax.arrow_left_1_bold), onPressed: () => context.pop()),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Container
              Container(
                    padding: EdgeInsets.all(24.r),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: hasCustomIcon
                        ? WdImagePreview(imageUrl: iconUrl!, size: 64, shape: BoxShape.circle)
                        : Icon(fallbackIcon, color: statusColor, size: 64.sp),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 3.seconds, color: statusColor.withValues(alpha: 0.2))
                  .shake(hz: 1, curve: Curves.easeInOut),

              SizedBox(height: 40.h),

              Text(
                title,
                style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w900, fontFamily: AppTheme.fontFamily, color: statusColor),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 100.ms).moveY(begin: 15),

              SizedBox(height: 16.h),

              Text(
                description,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms).moveY(begin: 15),

              SizedBox(height: 12.h),

              Text(
                subDescription,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey, fontFamily: AppTheme.fontFamily),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 500.ms).moveY(begin: 15),

              SizedBox(height: 60.h),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor == AppTheme.primaryColor ? statusColor : Colors.black87,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                    ),
                  ),
                  child: actionButton,
                ),
              ).animate().fadeIn(delay: 700.ms).scale(),

              if (status != null && status != 'null' && status!.isNotEmpty) ...[
                SizedBox(height: 12.h),
                TextButton(onPressed: () => context.pop(), child: Text(l10n.maybe_later)).animate().fadeIn(delay: 900.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Placeholder for support action
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.contact_support,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: const Icon(Iconsax.direct_right_bold, color: Colors.blue),
              title: Text(l10n.email_support),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Iconsax.whatsapp_bold, color: Colors.green),
              title: Text(l10n.chat_on_whatsapp),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
