import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/controllers/pv_system_designer_controller.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/wizard/wizard_intro_card.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/inputs/section_card.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/inputs/pv_number_field.dart';

class SiteSetupStep extends ConsumerStatefulWidget {
  const SiteSetupStep({super.key});

  @override
  ConsumerState<SiteSetupStep> createState() => _SiteSetupStepState();
}

class _SiteSetupStepState extends ConsumerState<SiteSetupStep> {
  late final TextEditingController _latController;
  late final TextEditingController _lonController;

  @override
  void initState() {
    super.initState();
    final s = ref.read(pvSystemDesignerProvider);
    _latController = TextEditingController(text: s.latitude.toStringAsFixed(4));
    _lonController = TextEditingController(text: s.longitude.toStringAsFixed(4));
  }

  @override
  void dispose() {
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pvSystemDesignerProvider);
    final controller = ref.read(pvSystemDesignerProvider.notifier);
    final isAr = Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WizardIntroCard(
            icon: Iconsax.location,
            titleEn: 'Site Location & Orientation',
            titleAr: 'موقع الموقع والاتجاه',
            descriptionEn: 'Set your location and preferred panel facing direction for optimal solar capture.',
            descriptionAr: 'حدد موقعك واتجاه الألواح المفضل لالتقاط أفضل طاقة شمسية.',
          ),
          SizedBox(height: 16.h),
          SectionCard(
            titleEn: 'GPS Location',
            titleAr: 'الموقع الجغرافي',
            icon: Iconsax.global,
            explanationEn: 'Your latitude determines the optimal tilt angle and sun path for maximum energy production.',
            explanationAr: 'يحدد خط العرض الخاص بك زاوية الميل المثالية ومسار الشمس لأقصى إنتاج للطاقة.',
            child: Column(
              children: [
                PvNumberField(
                  label: isAr ? 'خط العرض' : 'Latitude',
                  controller: _latController,
                  suffix: '°',
                  min: -90,
                  max: 90,
                  onChanged: (v) => controller.updateLatitude(v),
                ),
                PvNumberField(
                  label: isAr ? 'خط الطول' : 'Longitude',
                  controller: _lonController,
                  suffix: '°',
                  min: -180,
                  max: 180,
                  onChanged: (v) => controller.updateLongitude(v),
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: state.isLocationLoading
                        ? null
                        : () async {
                            await controller.useCurrentLocation();
                            if (mounted) {
                              final s = ref.read(pvSystemDesignerProvider);
                              _latController.text = s.latitude.toStringAsFixed(4);
                              _lonController.text = s.longitude.toStringAsFixed(4);
                            }
                          },
                    icon: state.isLocationLoading
                        ? SizedBox(width: 16.w, height: 16.h, child: const CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Iconsax.location_tick),
                    label: Text(
                      state.isLocationLoading
                          ? (isAr ? 'جاري الحصول على الموقع...' : 'Getting location...')
                          : (isAr ? 'استخدام الموقع الحالي' : 'Use Current Location'),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                ),
                if (state.locationError != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    state.locationError!,
                    style: TextStyle(color: Colors.redAccent, fontSize: 11.sp),
                  ),
                ],
              ],
            ),
          ),
          SectionCard(
            titleEn: 'Facing Direction',
            titleAr: 'اتجاه الألواح',
            icon: Icons.explore,
            explanationEn: 'In the northern hemisphere, panels should face south for maximum production.',
            explanationAr: 'في النصف الشمالي من الكرة الأرضية، يجب أن تواجه الألواح الجنوب لأقصى إنتاج.',
            child: DropdownButtonFormField<FacingDirectionPreference>(
              initialValue: state.facingPreference,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: isAr ? 'الاتجاه المفضل' : 'Preferred Direction',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              ),
              items: FacingDirectionPreference.values.map((f) {
                final labels = {
                  FacingDirectionPreference.any: isAr ? 'تلقائي (الأفضل)' : 'Auto (Optimal)',
                  FacingDirectionPreference.north: isAr ? 'شمال' : 'North',
                  FacingDirectionPreference.northEast: isAr ? 'شمال شرق' : 'North-East',
                  FacingDirectionPreference.east: isAr ? 'شرق' : 'East',
                  FacingDirectionPreference.southEast: isAr ? 'جنوب شرق' : 'South-East',
                  FacingDirectionPreference.south: isAr ? 'جنوب' : 'South',
                  FacingDirectionPreference.southWest: isAr ? 'جنوب غرب' : 'South-West',
                  FacingDirectionPreference.west: isAr ? 'غرب' : 'West',
                  FacingDirectionPreference.northWest: isAr ? 'شمال غرب' : 'North-West',
                };
                return DropdownMenuItem(value: f, child: Text(labels[f]!));
              }).toList(),
              onChanged: (v) {
                if (v != null) controller.updateFacingPreference(v);
              },
            ),
          ),
          SectionCard(
            titleEn: 'Mount Type',
            titleAr: 'نوع التركيب',
            icon: Iconsax.buildings,
            child: DropdownButtonFormField<MountType>(
              initialValue: state.mountType,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: isAr ? 'نوع التركيب' : 'Mount Type',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              ),
              items: MountType.values.map((m) {
                final labels = {
                  MountType.ground: isAr ? 'أرضي' : 'Ground Mount',
                  MountType.flatRoof: isAr ? 'سطح مسطح' : 'Flat Roof',
                  MountType.pitchedRoof: isAr ? 'سطح مائل' : 'Pitched Roof',
                  MountType.custom: isAr ? 'مخصص' : 'Custom',
                };
                return DropdownMenuItem(value: m, child: Text(labels[m]!));
              }).toList(),
              onChanged: (v) {
                if (v != null) controller.updateMountType(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}
