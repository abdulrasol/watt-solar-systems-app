import 'package:flutter_test/flutter_test.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/panel_layout.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/services/energy_estimator.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/services/solar_position_calculator.dart';

void main() {
  group('SolarPositionCalculator', () {
    const calculator = SolarPositionCalculator();

    test('noon sun is near south for northern hemisphere', () {
      final position = calculator.calculate(
        dateTime: DateTime.utc(2024, 6, 15, 12, 0),
        latitude: 33.3,
        longitude: 0.0,
      );

      expect(position.elevationDeg, greaterThan(70.0));
      expect(position.azimuthDeg, closeTo(180.0, 10.0));
    });

    test('midnight sun is below horizon', () {
      final position = calculator.calculate(
        dateTime: DateTime.utc(2024, 6, 15, 0, 0),
        latitude: 33.3,
        longitude: 0.0,
      );

      expect(position.elevationDeg, lessThan(0.0));
      expect(position.isDaytime, isFalse);
    });
  });

  group('EnergyEstimator fallback', () {
    const estimator = EnergyEstimator();

    test('produces positive yearly energy for a simple layout', () {
      final state = PvSystemDesignState.initial();
      final layout = state.layout.copyWith(
        cells: List.generate(
          state.layout.rows * state.layout.cols,
          (i) => i < 10 ? PvCellType.panel : PvCellType.empty,
        ),
      );

      final energy = estimator.estimateFallback(
        site: state.site,
        panelSpec: state.panelSpec,
        layout: layout,
        shading: state.shading,
      );

      expect(energy.yearlyKwh, greaterThan(0.0));
      expect(energy.monthlyKwh.length, 12);
      expect(energy.peakKw, closeTo(10 * 620 / 1000, 0.01));
    });
  });
}
