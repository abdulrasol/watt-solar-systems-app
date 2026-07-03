import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:solar_hub/src/features/structure_design/data/drawing/watt_drawing_file_service.dart';
import 'package:solar_hub/src/features/structure_design/data/location_service.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/drawing/watt_drawing_document.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/panel_spec.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/structure_design_input.dart';
import 'package:solar_hub/src/features/structure_design/domain/services/structure_design_calculator.dart';
import 'package:solar_hub/src/features/structure_design/presentation/utils/debounce_util.dart';

final structureDesignCalculatorProvider = Provider<StructureDesignCalculator>((ref) {
  return StructureDesignCalculator();
});

final structureLocationServiceProvider = Provider<LocationService>((ref) {
  return GeolocatorLocationService();
});

final wattDrawingFileServiceProvider = Provider<WattDrawingFileService>((ref) {
  return WattDrawingFileService();
});

final structureDesignControllerProvider = ChangeNotifierProvider.autoDispose.family<StructureDesignController, StructureDesignInput?>((ref, initialInput) {
  return StructureDesignController(
    calculator: ref.read(structureDesignCalculatorProvider),
    locationService: ref.read(structureLocationServiceProvider),
    initialInput: initialInput,
  );
});

class StructureDesignController extends ChangeNotifier {
  StructureDesignController({required StructureDesignCalculator calculator, required LocationService locationService, StructureDesignInput? initialInput})
    : _calculator = calculator,
      _locationService = locationService,
      _input =
          initialInput ??
          const StructureDesignInput(
            siteWidthMeters: 10,
            siteDepthMeters: 8,
            latitude: 33.3,
            facingPreference: FacingDirectionPreference.any,
            mountType: MountType.ground,
            frontClearanceMeters: 0.5,
            rearClearanceMeters: 0.5,
            sideClearanceMeters: 0.3,
            frontLegClearanceMeters: 0.5,
            interRowGapMeters: 0.5,
            rowMode: RowMode.independent,
            rowBaseOffsetsMeters: <double>[0.0],
            panelSpec: PanelSpec(
              lengthMeters: 2.28,
              widthMeters: 1.13,
              thicknessMeters: 0.035,
              orientation: PanelOrientation.portrait,
              horizontalGapMeters: 0.03,
              verticalGapMeters: 0.03,
            ),
          ),
      _debouncer = Debouncer(milliseconds: 300) {
    recalculate();
  }

  final StructureDesignCalculator _calculator;
  final LocationService _locationService;
  final Debouncer _debouncer;

  StructureDesignInput _input;
  FrameResult? _result;
  bool _isLocating = false;
  String? _locationMessage;

  StructureDesignInput get input => _input;
  FrameResult? get result => _result;
  bool get isLocating => _isLocating;
  String? get locationMessage => _locationMessage;

  bool get supportsSelectedMountType => _input.mountType == MountType.ground;
  List<double> get rowBaseOffsetsMeters => _input.rowBaseOffsetsMeters;
  int get activeRowCount => _input.manualRows ?? _result?.rows ?? 0;

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  void recalculate() {
    _syncRowOffsetsBeforeCalculation();
    _result = _calculator.calculate(_input);
    notifyListeners();
  }

  void updateSiteWidth(double value) {
    _input = _input.copyWith(siteWidthMeters: value);
    _debouncer.run(recalculate);
  }

  void updateSiteDepth(double value) {
    _input = _input.copyWith(siteDepthMeters: value);
    _debouncer.run(recalculate);
  }

  void updateLatitude(double value) {
    _input = _input.copyWith(latitude: value);
    _locationMessage = null;
    _debouncer.run(recalculate);
  }

  void updateFacingPreference(FacingDirectionPreference value) {
    _input = _input.copyWith(facingPreference: value);
    _debouncer.run(recalculate);
  }

  void updateMountType(MountType value) {
    _input = _input.copyWith(mountType: value);
    _debouncer.run(recalculate);
  }

  void updateRowMode(RowMode value) {
    _input = _input.copyWith(rowMode: value);
    _debouncer.run(recalculate);
  }

  void updateFrontClearance(double value) {
    _input = _input.copyWith(frontClearanceMeters: value);
    _debouncer.run(recalculate);
  }

  void updateRearClearance(double value) {
    _input = _input.copyWith(rearClearanceMeters: value);
    _debouncer.run(recalculate);
  }

  void updateSideClearance(double value) {
    _input = _input.copyWith(sideClearanceMeters: value);
    _debouncer.run(recalculate);
  }

  void updateFrontLegClearance(double value) {
    _input = _input.copyWith(frontLegClearanceMeters: value);
    _debouncer.run(recalculate);
  }

  void updateInterRowGap(double value) {
    _input = _input.copyWith(interRowGapMeters: value);
    _debouncer.run(recalculate);
  }

  void updatePanelLength(double value) {
    _input = _input.copyWith(panelSpec: _input.panelSpec.copyWith(lengthMeters: value));
    _debouncer.run(recalculate);
  }

  void updatePanelWidth(double value) {
    _input = _input.copyWith(panelSpec: _input.panelSpec.copyWith(widthMeters: value));
    _debouncer.run(recalculate);
  }

  void updatePanelThickness(double value) {
    _input = _input.copyWith(panelSpec: _input.panelSpec.copyWith(thicknessMeters: value));
    _debouncer.run(recalculate);
  }

  void updateHorizontalGap(double value) {
    _input = _input.copyWith(panelSpec: _input.panelSpec.copyWith(horizontalGapMeters: value));
    _debouncer.run(recalculate);
  }

  void updateVerticalGap(double value) {
    _input = _input.copyWith(panelSpec: _input.panelSpec.copyWith(verticalGapMeters: value));
    _debouncer.run(recalculate);
  }

  void updatePanelOrientation(PanelOrientation value) {
    _input = _input.copyWith(panelSpec: _input.panelSpec.copyWith(orientation: value), clearManualRows: true, clearManualColumns: true);
    recalculate();
  }

  void resetAutoLayout() {
    _input = _input.copyWith(clearManualRows: true, clearManualColumns: true);
    recalculate();
  }

  void loadWattDrawing(WattDrawingDocument document) {
    _input = document.input;
    _result = document.result;
    _locationMessage = null;
    notifyListeners();
  }

  void incrementRows() {
    final maxRows = _result?.maxRows ?? 0;
    final current = _input.manualRows ?? _result?.rows ?? 0;
    if (current >= maxRows) return;
    _input = _input.copyWith(manualRows: current + 1);
    recalculate();
  }

  void decrementRows() {
    final current = _input.manualRows ?? _result?.rows ?? 0;
    if (current <= 1) return;
    _input = _input.copyWith(manualRows: current - 1);
    recalculate();
  }

  void incrementColumns() {
    final maxColumns = _result?.maxColumns ?? 0;
    final current = _input.manualColumns ?? _result?.columns ?? 0;
    if (current >= maxColumns) return;
    _input = _input.copyWith(manualColumns: current + 1);
    recalculate();
  }

  void decrementColumns() {
    final current = _input.manualColumns ?? _result?.columns ?? 0;
    if (current <= 1) return;
    _input = _input.copyWith(manualColumns: current - 1);
    recalculate();
  }

  void updateRowBaseOffset(int index, double value) {
    final offsets = List<double>.from(_input.rowBaseOffsetsMeters);
    while (offsets.length <= index) {
      offsets.add(0);
    }
    offsets[index] = value;
    _input = _input.copyWith(rowBaseOffsetsMeters: offsets);
    recalculate();
  }

  /// Fetches the current location and updates the latitude for calculations.
  /// Returns true if successful, false otherwise.
  Future<bool> useCurrentLocation() async {
    _isLocating = true;
    _locationMessage = null;
    notifyListeners();
    try {
      final location = await _locationService.getCurrentLocation();
      _input = _input.copyWith(latitude: location.latitude);
      _locationMessage = null;
      return true;
    } on LocationException catch (e) {
      _locationMessage = e.message;
      return false;
    } catch (error) {
      _locationMessage = 'Failed to get location: \$error';
      return false;
    } finally {
      _isLocating = false;
      _debouncer.run(recalculate);
    }
  }

  /// Checks the current location permission status.
  Future<LocationPermission> checkLocationPermission() async {
    return await _locationService.checkPermission();
  }

  /// Opens app settings to allow the user to enable location permission.
  Future<void> openLocationSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Opens device location settings to enable GPS.
  Future<void> openDeviceLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  void _syncRowOffsetsBeforeCalculation() {
    final desiredCount = (_input.manualRows ?? _result?.rows ?? 1).clamp(1, 999);
    final offsets = List<double>.from(_input.rowBaseOffsetsMeters);
    if (offsets.length == desiredCount) {
      return;
    }
    final nextOffsets = List<double>.generate(desiredCount, (index) {
      if (index < offsets.length) {
        return offsets[index];
      }
      return 0.0;
    });
    _input = _input.copyWith(rowBaseOffsetsMeters: nextOffsets);
  }
}
