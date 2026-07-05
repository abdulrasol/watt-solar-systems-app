import 'package:flutter_test/flutter_test.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/panel_spec.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/structure_design_input.dart';
import 'package:solar_hub/src/features/structure_design/domain/services/structure_design_calculator.dart';

void main() {
  final calculator = StructureDesignCalculator();

  StructureDesignInput buildInput({
    double latitude = 33.3,
    FacingDirectionPreference facingPreference = FacingDirectionPreference.any,
    PanelOrientation orientation = PanelOrientation.portrait,
    RowMode rowMode = RowMode.independent,
    List<double> rowBaseOffsetsMeters = const <double>[0, 0, 0],
    int? manualRows,
    int? manualColumns,
  }) {
    return StructureDesignInput(
      siteWidthMeters: 12,
      siteDepthMeters: 8,
      latitude: latitude,
      facingPreference: facingPreference,
      mountType: MountType.ground,
      frontClearanceMeters: 0.5,
      rearClearanceMeters: 0.5,
      sideClearanceMeters: 0.3,
      frontLegClearanceMeters: 0.5,
      interRowGapMeters: 0.5,
      rowMode: rowMode,
      rowBaseOffsetsMeters: rowBaseOffsetsMeters,
      manualRows: manualRows,
      manualColumns: manualColumns,
      panelSpec: PanelSpec(
        lengthMeters: 2.28,
        widthMeters: 1.13,
        thicknessMeters: 0.035,
        orientation: orientation,
        horizontalGapMeters: 0.03,
        verticalGapMeters: 0.03,
      ),
    );
  }

  test('northern hemisphere chooses south by default', () {
    final result = calculator.calculate(buildInput(latitude: 33.3));

    expect(result.idealAzimuthDegrees, 180);
    expect(result.appliedAzimuthDegrees, 180);
    expect(result.isOrientationConstrained, isFalse);
  });

  test('southern hemisphere chooses north by default', () {
    final result = calculator.calculate(buildInput(latitude: -18.0));

    expect(result.idealAzimuthDegrees, 0);
    expect(result.appliedAzimuthDegrees, 0);
  });

  test('constrained direction chooses nearest allowed azimuth', () {
    final result = calculator.calculate(
      buildInput(
        latitude: 33.3,
        facingPreference: FacingDirectionPreference.east,
      ),
    );

    expect(result.appliedAzimuthDegrees, 90);
    expect(result.isOrientationConstrained, isTrue);
  });

  test('tilt clamps correctly at low and high latitude', () {
    expect(calculator.resolveTilt(3), 10);
    expect(calculator.resolveTilt(51), 40);
  });

  test('panel count fits within area', () {
    final result = calculator.calculate(buildInput());

    expect(result.panelCount, greaterThan(0));
    expect(
      result.frameWidthMeters,
      lessThanOrEqualTo(result.usableWidthMeters),
    );
    expect(result.totalFootprintDepthMeters, lessThanOrEqualTo(8.0 + 1e-6));
  });

  test('portrait and landscape layouts produce different counts', () {
    final portrait = calculator.calculate(
      buildInput(orientation: PanelOrientation.portrait),
    );
    final landscape = calculator.calculate(
      buildInput(orientation: PanelOrientation.landscape),
    );

    expect(landscape.panelCount, isNot(portrait.panelCount));
  });

  test('row spacing reduces usable depth for multi-row layouts', () {
    final result = calculator.calculate(buildInput());

    expect(result.rowSpacingMeters, greaterThan(0.5));
    expect(
      result.totalFootprintDepthMeters,
      greaterThan(result.projectedRowDepthMeters),
    );
  });

  test('rear height increases with tilt and brace stays positive', () {
    final lowTilt = calculator.calculate(buildInput(latitude: 10));
    final highTilt = calculator.calculate(buildInput(latitude: 40));

    expect(
      highTilt.rearLegHeightMeters,
      greaterThan(lowTilt.rearLegHeightMeters),
    );
    expect(highTilt.braceLengthMeters, greaterThan(0));
    expect(highTilt.railLengthMeters, greaterThan(0));
  });

  test('independent rows keep repeated leg geometry', () {
    final result = calculator.calculate(buildInput());

    expect(result.rowMode, RowMode.independent);
    expect(result.isUniformLegDesign, isTrue);
    expect(result.rowResults, isNotEmpty);
    expect(
      result.rowResults.every(
        (row) =>
            row.frontLegHeightMeters == result.frontLegHeightMeters &&
            row.rearLegHeightMeters == result.rearLegHeightMeters,
      ),
      isTrue,
    );
  });

  test('stepped rows change per-row leg heights when offsets differ', () {
    final result = calculator.calculate(
      buildInput(
        rowMode: RowMode.stepped,
        rowBaseOffsetsMeters: const <double>[0, 0.25, 0.5],
      ),
    );

    expect(result.rowMode, RowMode.stepped);
    expect(result.isUniformLegDesign, isFalse);
    expect(
      result.rowResults.last.frontLegHeightMeters,
      greaterThan(result.rowResults.first.frontLegHeightMeters),
    );
    expect(
      result.rowResults.last.rearLegHeightMeters,
      greaterThan(result.rowResults.first.rearLegHeightMeters),
    );
  });

  test('zero stepped offsets match independent geometry', () {
    final independent = calculator.calculate(buildInput());
    final stepped = calculator.calculate(
      buildInput(
        rowMode: RowMode.stepped,
        rowBaseOffsetsMeters: const <double>[0, 0, 0],
      ),
    );

    expect(stepped.frontLegHeightMeters, independent.frontLegHeightMeters);
    expect(stepped.rearLegHeightMeters, independent.rearLegHeightMeters);
    expect(stepped.minRearLegHeightMeters, independent.rearLegHeightMeters);
    expect(stepped.maxRearLegHeightMeters, independent.rearLegHeightMeters);
  });

  test('bom counts scale with rows and columns', () {
    final result = calculator.calculate(buildInput());

    expect(
      result.frontLegCount,
      equals(result.supportStationCount * result.rows),
    );
    expect(
      result.rearLegCount,
      equals(result.supportStationCount * result.rows),
    );
    expect(
      result.anchorCount,
      equals(result.frontLegCount + result.rearLegCount),
    );
  });

  test('support station count increases as frame width grows', () {
    final narrow = calculator.calculate(buildInput(manualColumns: 2));
    final wide = calculator.calculate(buildInput(manualColumns: 6));

    expect(wide.frameWidthMeters, greaterThan(narrow.frameWidthMeters));
    expect(wide.supportStationCount, greaterThan(narrow.supportStationCount));
    expect(wide.supportSpacingMeters, 1.6);
  });

  test('three panel row uses more than two support stations', () {
    final result = calculator.calculate(buildInput(manualColumns: 3));

    expect(result.columns, 3);
    expect(result.supportStationCount, greaterThan(2));
  });

  test('total steel length sums rails braces and legs in independent mode', () {
    final result = calculator.calculate(buildInput());

    expect(
      result.totalSteelLengthMeters,
      closeTo(
        result.railLengthMeters +
            result.totalFrontLegLengthMeters +
            result.totalRearLegLengthMeters +
            result.totalBraceLengthMeters,
        1e-9,
      ),
    );
  });

  test('stepped mode total steel length uses row-specific leg lengths', () {
    final result = calculator.calculate(
      buildInput(
        rowMode: RowMode.stepped,
        rowBaseOffsetsMeters: const <double>[0, 0.25, 0.5],
      ),
    );

    final expectedFront = result.rowResults.fold<double>(
      0,
      (sum, row) =>
          sum + (row.frontLegHeightMeters * result.supportStationCount),
    );
    final expectedRear = result.rowResults.fold<double>(
      0,
      (sum, row) =>
          sum + (row.rearLegHeightMeters * result.supportStationCount),
    );

    expect(result.totalFrontLegLengthMeters, closeTo(expectedFront, 1e-9));
    expect(result.totalRearLegLengthMeters, closeTo(expectedRear, 1e-9));
    expect(
      result.totalSteelLengthMeters,
      closeTo(
        result.railLengthMeters +
            expectedFront +
            expectedRear +
            result.totalBraceLengthMeters,
        1e-9,
      ),
    );
  });

  test('anchors are not included in total steel length', () {
    final result = calculator.calculate(buildInput());

    expect(
      result.totalSteelLengthMeters,
      lessThan(
        result.railLengthMeters +
            result.totalFrontLegLengthMeters +
            result.totalRearLegLengthMeters +
            result.totalBraceLengthMeters +
            result.anchorCount,
      ),
    );
  });
}
