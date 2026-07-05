import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/shared/domain/service_type.dart';
import 'package:solar_hub/src/features/services/domain/entities/service_type_visual.dart';

class CompanyTypeCard extends StatelessWidget {
  final ServiceType type;
  final VoidCallback onTap;

  const CompanyTypeCard({super.key, required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final visual = resolveServiceTypeVisual(type.name);
    final l10n = AppLocalizations.of(context)!;
    final label = _displayLabel(type);
    final description = _displayDescription(type, label);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: visual.colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [BoxShadow(color: visual.colors.last.withValues(alpha: 0.25), blurRadius: 18, offset: const Offset(0, 10))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(14.r)),
                    child: type.image?.isNotEmpty == true
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14.r),
                            child: CachedNetworkImage(
                              imageUrl: type.image!,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) => Icon(visual.icon, color: Colors.white.withValues(alpha: 0.88), size: 22.sp),
                            ),
                          )
                        : Icon(visual.icon, color: Colors.white.withValues(alpha: 0.88), size: 22.sp),
                  ),
                ),
                Positioned(
                  bottom: -14,
                  left: -10,
                  child: CircleAvatar(radius: 22.r, backgroundColor: Colors.black.withValues(alpha: 0.08)),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.biggest.shortestSide < 190;
                    final cardPadding = isCompact ? 14.r : 18.r;
                    final titleFontSize = isCompact ? 16.sp : 18.sp;
                    final descriptionFontSize = isCompact ? 10.sp : 11.sp;
                    final chipFontSize = isCompact ? 10.sp : 11.sp;
                    final countFontSize = isCompact ? 11.sp : 12.sp;
                    final topGap = isCompact ? 22.h : 28.h;
                    final descriptionGap = isCompact ? 4.h : 6.h;
                    final actionGap = isCompact ? 6.h : 8.h;
                    final chipPadding = EdgeInsets.symmetric(horizontal: isCompact ? 9.w : 10.w, vertical: isCompact ? 4.h : 6.h);

                    return Padding(
                      padding: EdgeInsets.all(cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: topGap),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    label,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: titleFontSize, height: 1.2),
                                  ),
                                ),
                                if (description != null) ...[
                                  SizedBox(height: descriptionGap),
                                  Flexible(
                                    child: Text(
                                      description,
                                      maxLines: isCompact ? 1 : 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.88), fontSize: descriptionFontSize, height: 1.3),
                                    ),
                                  ),
                                ],
                                SizedBox(height: actionGap),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: chipPadding,
                                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(999.r)),
                                        child: Text(
                                          l10n.services_explore_companies,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.white, fontSize: chipFontSize, fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      '${type.companiesCount}',
                                      style: TextStyle(color: Colors.white, fontSize: countFontSize, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _displayLabel(ServiceType type) {
    final text = type.name.trim();
    return text.replaceAll('_', ' ').replaceAll('-', ' ');
  }

  String? _displayDescription(ServiceType type, String label) {
    final description = type.description?.trim();
    if (description == null || description.isEmpty) {
      return null;
    }

    final normalizedDescription = _normalizeDisplayText(description);
    final normalizedLabel = _normalizeDisplayText(label);
    if (normalizedDescription == normalizedLabel) {
      return null;
    }

    return description;
  }

  String _normalizeDisplayText(String text) {
    return text.trim().replaceAll('_', ' ').replaceAll('-', ' ').toLowerCase();
  }
}

ServiceTypeVisual resolveServiceTypeVisual(String code) {
  final normalized = code.trim().toLowerCase();

  if (normalized.contains('install') || normalized.contains('تركيب')) {
    return const ServiceTypeVisual(colors: [Color(0xFFFF8A26), Color(0xFFFFB347)], icon: Iconsax.flash_1);
  }
  if (normalized.contains('maint') || normalized.contains('صيانة')) {
    return const ServiceTypeVisual(colors: [Color(0xFF1CCACF), Color(0xFF1982C4)], icon: Iconsax.setting_2);
  }
  if (normalized.contains('inverter') || normalized.contains('انفرتر')) {
    return const ServiceTypeVisual(colors: [Color(0xFF7A5CFA), Color(0xFFB388FF)], icon: Iconsax.cpu);
  }
  if (normalized.contains('battery') || normalized.contains('بطارية')) {
    return const ServiceTypeVisual(colors: [Color(0xFF47C266), Color(0xFF9BE15D)], icon: Iconsax.battery_full);
  }
  if (normalized.contains('panel') || normalized.contains('ألواح')) {
    return const ServiceTypeVisual(colors: [Color(0xFF219EBC), Color(0xFF8ECAE6)], icon: Icons.wb_sunny_rounded);
  }
  return const ServiceTypeVisual(colors: [Color(0xFFFF6B6B), Color(0xFFFFA36C)], icon: Iconsax.buildings_2);
}
