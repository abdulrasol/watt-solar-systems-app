import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:solar_hub/src/features/structure_design/data/location_service.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/panel_spec.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/structure_design_input.dart';
import 'package:solar_hub/src/features/structure_design/domain/services/structure_design_calculator.dart';

final structureDesignCalculatorProvider = Provider<StructureDesignCalculator>((
  ref,
) {
  return StructureDesignCalculator();
});

final structureLocationServiceProvider = Provider<LocationService>((ref) {
  return GeolocatorLocationService();
});

final structureDesignControllerProvider =
    ChangeNotifierProvider.autoDispose<StructureDesignController>((ref) {
      return StructureDesignController(
        calculator: ref.read(structureDesignCalculatorProvider),
        locationService: ref.read(structureLocationServiceProvider),
      );
    });

class StructureDesignController extends ChangeNotifier {
  StructureDesignController({
    required StructureDesignCalculator calculator,
    required LocationService locationService,
  }) : _calculator = calculator,
       _locationService = locationService,
       _input = const StructureDesignInput(
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
       ) {
    recalculate();
  }

  final StructureDesignCalculator _calculator;
  final LocationService _locationService;

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

  void recalculate() {
    _syncRowOffsetsBeforeCalculation();
    _result = _calculator.calculate(_input);
    notifyListeners();
  }

  void updateSiteWidth(double value) {
    _input = _input.copyWith(siteWidthMeters: value);
    recalculate();
  }

  void updateSiteDepth(double value) {
    _input = _input.copyWith(siteDepthMeters: value);
    recalculate();
  }

  void updateLatitude(double value) {
    _input = _input.copyWith(latitude: value);
    _locationMessage = null;
    recalculate();
  }

  void updateFacingPreference(FacingDirectionPreference value) {
    _input = _input.copyWith(facingPreference: value);
    recalculate();
  }

  void updateMountType(MountType value) {
    _input = _input.copyWith(mountType: value);
    recalculate();
  }

  void updateRowMode(RowMode value) {
    _input = _input.copyWith(rowMode: value);
    recalculate();
  }

  void updateFrontClearance(double value) {
    _input = _input.copyWith(frontClearanceMeters: value);
    recalculate();
  }

  void updateRearClearance(double value) {
    _input = _input.copyWith(rearClearanceMeters: value);
    recalculate();
  }

  void updateSideClearance(double value) {
    _input = _input.copyWith(sideClearanceMeters: value);
    recalculate();
  }

  void updateFrontLegClearance(double value) {
    _input = _input.copyWith(frontLegClearanceMeters: value);
    recalculate();
  }

  void updateInterRowGap(double value) {
    _input = _input.copyWith(interRowGapMeters: value);
    recalculate();
  }

  void updatePanelLength(double value) {
    _input = _input.copyWith(
      panelSpec: _input.panelSpec.copyWith(lengthMeters: value),
    );
    recalculate();
  }

  void updatePanelWidth(double value) {
    _input = _input.copyWith(
      panelSpec: _input.panelSpec.copyWith(widthMeters: value),
    );
    recalculate();
  }

  void updatePanelThickness(double value) {
    _input = _input.copyWith(
      panelSpec: _input.panelSpec.copyWith(thicknessMeters: value),
    );
    recalculate();
  }

  void updateHorizontalGap(double value) {
    _input = _input.copyWith(
      panelSpec: _input.panelSpec.copyWith(horizontalGapMeters: value),
    );
    recalculate();
  }

  void updateVerticalGap(double value) {
    _input = _input.copyWith(
      panelSpec: _input.panelSpec.copyWith(verticalGapMeters: value),
    );
    recalculate();
  }

  void updatePanelOrientation(PanelOrientation value) {
    _input = _input.copyWith(
      panelSpec: _input.panelSpec.copyWith(orientation: value),
      clearManualRows: true,
      clearManualColumns: true,
    );
    recalculate();
  }

  void resetAutoLayout() {
    _input = _input.copyWith(clearManualRows: true, clearManualColumns: true);
    recalculate();
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

  Future<void> useCurrentLocation() async {
    _isLocating = true;
    _locationMessage = null;
    notifyListeners();
    try {
      final latitude = await _locationService.getCurrentLatitude();
      _input = _input.copyWith(latitude: latitude);
      _locationMessage = null;
    } catch (error) {
      _locationMessage = error.toString();
    } finally {
      _isLocating = false;
      recalculate();
    }
  }

  void _syncRowOffsetsBeforeCalculation() {
    final desiredCount = (_input.manualRows ?? _result?.rows ?? 1).clamp(
      1,
      999,
    );
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
