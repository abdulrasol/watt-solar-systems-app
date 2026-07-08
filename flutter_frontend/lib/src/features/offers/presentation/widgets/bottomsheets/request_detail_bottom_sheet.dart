import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:watt/l10n/app_localizations.dart';
import 'package:watt/src/utils/app_enums.dart';
import 'package:watt/src/utils/app_theme.dart';
import 'package:watt/src/features/offers/domain/entities/solar_request.dart';
import 'package:watt/src/features/offers/presentation/screens/form/offer_reply_form.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestDetailBottomSheet extends ConsumerWidget {
  final SolarRequest request;

  const RequestDetailBottomSheet({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
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
                l10n.solar_request_details,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, fontFamily: AppTheme.fontFamily),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Iconsax.close_circle)),
            ],
          ),
          const Divider(),
          SizedBox(height: 16.h),

          Text(
            l10n.requester_info,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 8.h),
          // Requester Section
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                backgroundImage: request.user?.image != null ? NetworkImage(request.user!.image!) : null,
                child: request.user?.image == null ? Icon(Iconsax.user, size: 24.sp, color: AppTheme.primaryColor) : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.user?.name ?? l10n.unknown_user,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Icon(Iconsax.location, size: 12.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Text(
                          request.city?.name ?? '-',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (request.user?.phone != null)
                IconButton(
                  onPressed: () => launchUrl(Uri.parse('tel:${request.user!.phone}')),
                  icon: Icon(Iconsax.call, color: Colors.green, size: 24.sp),
                ),
              if (request.user?.email != null)
                IconButton(
                  onPressed: () => launchUrl(Uri.parse('mailto:${request.user!.email}')),
                  icon: Icon(Iconsax.sms, color: Colors.blue, size: 24.sp),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          const Divider(),
          SizedBox(height: 16.h),

          Text(
            l10n.user_needs,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: AppTheme.primaryColor),
          ),
          SizedBox(height: 12.h),
          _buildSpecGrid(context),

          if (request.note != null && request.note!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              l10n.technical_notes,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              request.note!,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
            ),
          ],

          SizedBox(height: 32.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => OfferReplyForm(request: request)));
              },
              icon: const Icon(Iconsax.flash_1),
              label: Text(l10n.send_offer_for_request),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Iconsax.close_circle), label: Text(l10n.cancel)),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecGrid(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3,
      children: [
        _buildMiniSpec(l10n.panels_power, l10n.unit_watts(request.totalPanelPower)),
        _buildMiniSpec(l10n.battery_power, l10n.unit_watthours(_formatNumber(request.totalBatteryPower))),
        _buildMiniSpec(l10n.inverter_calc, '${l10n.unit_watts(_formatNumber(request.totalInvertersPower))} (${request.inverterType.localizedLabel(l10n)})'),
        _buildMiniSpec(l10n.battery_type_full, request.batteryType.localizedLabel(l10n)),
      ],
    );
  }

  Widget _buildMiniSpec(String label, String value) {
    return Row(
      children: [
        const Icon(Iconsax.verify, size: 14, color: AppTheme.primaryColor),
        SizedBox(width: 4.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 8.sp, color: Colors.grey),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  String _formatNumber(num value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }
}
