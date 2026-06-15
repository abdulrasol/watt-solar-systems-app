import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:solar_hub/l10n/app_localizations.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/site_profile.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/controllers/pv_system_design_providers.dart';
import 'package:solar_hub/src/features/pv_system_designer/presentation/widgets/inputs/pv_number_field.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/structure_design_input.dart';
import 'package:solar_hub/src/utils/app_theme.dart';

class SiteStep extends ConsumerStatefulWidget {
  const SiteStep({super.key});

  static final formKey = GlobalKey<FormState>();

  @override
  ConsumerState<SiteStep> createState() => _SiteStepState();
}

class _SiteStepState extends ConsumerState<SiteStep> {
  late final TextEditingController _nameController;
  late final TextEditingController _latController;
  late final TextEditingController _lonController;
  late final TextEditingController _widthController;
  late final TextEditingController _lengthController;
  late final TextEditingController _pitchController;
  late final TextEditingController _azimuthController;
  late final TextEditingController _setbackController;
  late final TextEditingController _frontClearanceController;
  late final TextEditingController _rearClearanceController;
  late final TextEditingController _sideClearanceController;
  late final TextEditingController _legClearanceController;
  late final TextEditingController _rowGapController;
  late final TextEditingController _tariffController;

  @override
  void initState() {
    super.initState();
    final site = ref.read(pvSystemDesignControllerProvider).site;
    final tariff = ref.read(pvSystemDesignControllerProvider).avgTariffPerKwh;
    _nameController = TextEditingController(text: site.locationName);
    _latController = TextEditingController(text: site.latitude.toStringAsFixed(4));
    _lonController = TextEditingController(text: site.longitude.toStringAsFixed(4));
    _widthController = TextEditingController(text: site.roofWidthM.toString());
    _lengthController = TextEditingController(text: site.roofLengthM.toString());
    _pitchController = TextEditingController(text: site.roofPitchDeg.toString());
    _azimuthController = TextEditingController(text: site.roofAzimuthDeg.toString());
    _setbackController = TextEditingController(text: site.wallSetbackM.toString());
    _frontClearanceController = TextEditingController(text: site.frontClearanceM.toString());
    _rearClearanceController = TextEditingController(text: site.rearClearanceM.toString());
    _sideClearanceController = TextEditingController(text: site.sideClearanceM.toString());
    _legClearanceController = TextEditingController(text: site.frontLegClearanceM.toString());
    _rowGapController = TextEditingController(text: site.interRowGapM.toString());
    _tariffController = TextEditingController(text: tariff.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latController.dispose();
    _lonController.dispose();
    _widthController.dispose();
    _lengthController.dispose();
    _pitchController.dispose();
    _azimuthController.dispose();
    _setbackController.dispose();
    _frontClearanceController.dispose();
    _rearClearanceController.dispose();
    _sideClearanceController.dispose();
    _legClearanceController.dispose();
    _rowGapController.dispose();
    _tariffController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    _latController.text = position.latitude.toStringAsFixed(4);
    _lonController.text = position.longitude.toStringAsFixed(4);
    _commit();
  }

  void _commit() {
    final notifier = ref.read(pvSystemDesignControllerProvider.notifier);
    notifier.updateSite(
      SiteProfile(
        locationName: _nameController.text,
        latitude: double.tryParse(_latController.text) ?? 24.7136,
        longitude: double.tryParse(_lonController.text) ?? 46.6753,
        roofWidthM: double.tryParse(_widthController.text) ?? 10.0,
        roofLengthM: double.tryParse(_lengthController.text) ?? 8.0,
        roofPitchDeg: double.tryParse(_pitchController.text) ?? 0.0,
        roofAzimuthDeg: double.tryParse(_azimuthController.text) ?? 180.0,
        mountType: ref.read(pvSystemDesignControllerProvider).site.mountType,
        wallSetbackM: double.tryParse(_setbackController.text) ?? 0.5,
        frontClearanceM: double.tryParse(_frontClearanceController.text) ?? 0.5,
        rearClearanceM: double.tryParse(_rearClearanceController.text) ?? 0.5,
        sideClearanceM: double.tryParse(_sideClearanceController.text) ?? 0.5,
        frontLegClearanceM: double.tryParse(_legClearanceController.text) ?? 0.3,
        interRowGapM: double.tryParse(_rowGapController.text) ?? 0.5,
      ),
    );
    notifier.updateTariff(double.tryParse(_tariffController.text) ?? 0.18);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(pvSystemDesignControllerProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.r),
      child: Form(
        key: SiteStep.formKey,
        onChanged: _commit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(l10n.pv_design_site_location),
            PvNumberField(
              label: l10n.pv_design_location_name,
              controller: _nameController,
              isText: true,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: PvNumberField(
                    label: l10n.pv_design_latitude,
                    controller: _latController,
                    suffix: '°',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PvNumberField(
                    label: l10n.pv_design_longitude,
                    controller: _lonController,
                    suffix: '°',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: _useCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: Text(l10n.pv_design_use_location),
              ),
            ),
            SizedBox(height: 20.h),
            _buildSectionTitle(l10n.pv_design_roof_dimensions),
            Row(
              children: [
                Expanded(
                  child: PvNumberField(
                    label: l10n.pv_design_width,
                    controller: _widthController,
                    suffix: 'm',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PvNumberField(
                    label: l10n.pv_design_length,
                    controller: _lengthController,
                    suffix: 'm',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _buildMountTypeChips(state.site.mountType),
            SizedBox(height: 20.h),
            _buildSectionTitle(l10n.pv_design_tilt_azimuth),
            Row(
              children: [
                Expanded(
                  child: PvNumberField(
                    label: l10n.pv_design_pitch,
                    controller: _pitchController,
                    suffix: '°',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PvNumberField(
                    label: l10n.pv_design_azimuth,
                    controller: _azimuthController,
                    suffix: '°',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            _buildSectionTitle(l10n.pv_design_clearances),
            Row(
              children: [
                Expanded(
                  child: PvNumberField(
                    label: l10n.pv_design_setback,
                    controller: _setbackController,
                    suffix: 'm',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PvNumberField(
                    label: l10n.pv_design_front_clearance,
                    controller: _frontClearanceController,
                    suffix: 'm',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: PvNumberField(
                    label: l10n.pv_design_rear_clearance,
                    controller: _rearClearanceController,
                    suffix: 'm',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PvNumberField(
                    label: l10n.pv_design_side_clearance,
                    controller: _sideClearanceController,
                    suffix: 'm',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: PvNumberField(
                    label: l10n.pv_design_leg_clearance,
                    controller: _legClearanceController,
                    suffix: 'm',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: PvNumberField(
                    label: l10n.pv_design_row_gap,
                    controller: _rowGapController,
                    suffix: 'm',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            _buildSectionTitle(l10n.pv_design_economics),
            PvNumberField(
              label: l10n.pv_design_tariff,
              controller: _tariffController,
              suffix: '\$/kWh',
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryColor,
            ),
      ),
    );
  }

  Widget _buildMountTypeChips(MountType current) {
    final notifier = ref.read(pvSystemDesignControllerProvider.notifier);
    final site = ref.read(pvSystemDesignControllerProvider).site;
    return Wrap(
      spacing: 8.w,
      children: MountType.values.map((type) {
        final selected = type == current;
        return ChoiceChip(
          label: Text(_mountTypeLabel(type)),
          selected: selected,
          onSelected: (_) {
            notifier.updateSite(site.copyWith(mountType: type));
          },
        );
      }).toList(),
    );
  }

  String _mountTypeLabel(MountType type) {
    return switch (type) {
      MountType.ground => 'Ground',
      MountType.flatRoof => 'Flat Roof',
      MountType.pitchedRoof => 'Pitched Roof',
      MountType.custom => 'Custom',
    };
  }
}
