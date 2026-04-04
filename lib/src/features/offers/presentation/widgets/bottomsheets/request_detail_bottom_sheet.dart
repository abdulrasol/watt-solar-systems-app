import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/utils/app_enums.dart';
import 'package:solar_hub/src/utils/app_theme.dart';
import 'package:solar_hub/src/features/offers/domain/entities/solar_request.dart';
import 'package:solar_hub/src/features/offers/presentation/screens/form/offer_reply_form.dart';

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
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Iconsax.close_circle_bold),
              ),
            ],
          ),
          const Divider(),
          SizedBox(height: 16.h),

          Text(
            l10n.user_needs,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: AppTheme.primaryColor,
            ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OfferReplyForm(request: request),
                  ),
                );
              },
              icon: const Icon(Iconsax.flash_1_bold),
              label: Text(l10n.send_offer_for_request),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Iconsax.close_circle_bold),
              label: Text(l10n.cancel),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 3,
      children: [
        _buildMiniSpec(
          AppLocalizations.of(context)!.panels_power,
          '${request.totalPanelPower}W',
        ),
        _buildMiniSpec(
          AppLocalizations.of(context)!.battery_power,
          '${_formatNumber(request.totalBatteryPower)}Wh',
        ),
        _buildMiniSpec(
          AppLocalizations.of(context)!.inverter_calc,
          '${_formatNumber(request.totalInvertersPower)}W (${request.inverterType.localizedLabel(AppLocalizations.of(context)!)})',
        ),
        _buildMiniSpec(
          AppLocalizations.of(context)!.battery_type_full,
          request.batteryType.localizedLabel(AppLocalizations.of(context)!),
        ),
      ],
    );
  }

  Widget _buildMiniSpec(String label, String value) {
    return Row(
      children: [
        const Icon(Iconsax.verify_bold, size: 14, color: AppTheme.primaryColor),
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
