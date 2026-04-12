import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/shared/domain/company/company_type.dart';
import 'package:solar_hub/src/features/services/domain/entities/service_type_visual.dart';

class CompanyTypeCard extends StatelessWidget {
  final CompanyType type;
  final VoidCallback onTap;

  const CompanyTypeCard({super.key, required this.type, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final visual = resolveServiceTypeVisual(type.code);
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24.r),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: visual.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: visual.colors.last.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Stack(
              children: [
                Positioned(
                  top: -16,
                  right: -8,
                  child: CircleAvatar(
                    radius: 32.r,
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                Positioned(
                  bottom: -14,
                  left: -10,
                  child: CircleAvatar(
                    radius: 22.r,
                    backgroundColor: Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(18.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: Icon(
                          visual.icon,
                          color: Colors.white.withValues(alpha: 0.88),
                          size: 24.sp,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _displayLabel(type),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18.sp,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          l10n.services_explore_companies,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _displayLabel(CompanyType type) {
    final text = type.name.trim().isEmpty ? type.code : type.name;
    return text.replaceAll('_', ' ').replaceAll('-', ' ');
  }
}

ServiceTypeVisual resolveServiceTypeVisual(String code) {
  final normalized = code.trim().toLowerCase();

  if (normalized.contains('install') || normalized.contains('تركيب')) {
    return const ServiceTypeVisual(
      colors: [Color(0xFFFF8A26), Color(0xFFFFB347)],
      icon: Iconsax.flash_1_bold,
    );
  }
  if (normalized.contains('maint') || normalized.contains('صيانة')) {
    return const ServiceTypeVisual(
      colors: [Color(0xFF1CCACF), Color(0xFF1982C4)],
      icon: Iconsax.setting_2_bold,
    );
  }
  if (normalized.contains('inverter') || normalized.contains('انفرتر')) {
    return const ServiceTypeVisual(
      colors: [Color(0xFF7A5CFA), Color(0xFFB388FF)],
      icon: Iconsax.cpu_bold,
    );
  }
  if (normalized.contains('battery') || normalized.contains('بطارية')) {
    return const ServiceTypeVisual(
      colors: [Color(0xFF47C266), Color(0xFF9BE15D)],
      icon: Iconsax.battery_full_bold,
    );
  }
  if (normalized.contains('panel') || normalized.contains('ألواح')) {
    return const ServiceTypeVisual(
      colors: [Color(0xFF219EBC), Color(0xFF8ECAE6)],
      icon: Icons.wb_sunny_rounded,
    );
  }
  return const ServiceTypeVisual(
    colors: [Color(0xFFFF6B6B), Color(0xFFFFA36C)],
    icon: Iconsax.buildings_2_bold,
  );
}
