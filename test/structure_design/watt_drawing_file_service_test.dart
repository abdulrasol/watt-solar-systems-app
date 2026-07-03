import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:solar_hub/src/features/structure_design/data/drawing/watt_drawing_file_service.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/drawing/watt_drawing_document.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/panel_spec.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/structure_design_input.dart';
import 'package:solar_hub/src/features/structure_design/domain/services/structure_design_calculator.dart';

void main() {
  final calculator = StructureDesignCalculator();
  final service = WattDrawingFileService(
    now: () => DateTime.utc(2026, 5, 8, 12),
  );

  StructureDesignInput buildInput({
    RowMode rowMode = RowMode.independent,
    List<double> rowBaseOffsetsMeters = const <double>[0, 0.25],
  }) {
    return StructureDesignInput(
      siteWidthMeters: 12,
      siteDepthMeters: 8,
      latitude: 33.3,
      facingPreference: FacingDirectionPreference.any,
      mountType: MountType.ground,
      frontClearanceMeters: 0.5,
      rearClearanceMeters: 0.5,
      sideClearanceMeters: 0.3,
      frontLegClearanceMeters: 0.5,
      interRowGapMeters: 0.5,
      panelSpec: const PanelSpec(
        lengthMeters: 2.28,
        widthMeters: 1.13,
        thicknessMeters: 0.035,
        orientation: PanelOrientation.portrait,
        horizontalGapMeters: 0.03,
        verticalGapMeters: 0.03,
      ),
      rowMode: rowMode,
      rowBaseOffsetsMeters: rowBaseOffsetsMeters,
      manualRows: 2,
    );
  }

  test('.wattd encode/decode round trip preserves structure data', () async {
    final input = buildInput(rowMode: RowMode.stepped);
    final result = calculator.calculate(input);

    final bytes = await service.encodeStructureDesign(
      title: 'South Frame',
      input: input,
      result: result,
      appVersion: '1.0.0+3',
    );
    final decoded = await service.decode(bytes);

    expect(decoded.title, 'South Frame');
    expect(decoded.documentType, wattDrawingDocumentTypeStructureDesign);
    expect(decoded.schemaVersion, wattDrawingSchemaVersion);
    expect(decoded.appVersion, '1.0.0+3');
    expect(decoded.input.siteWidthMeters, input.siteWidthMeters);
    expect(decoded.input.rowMode, RowMode.stepped);
    expect(decoded.result.panelCount, result.panelCount);
    expect(
      decoded.result.totalSteelLengthMeters,
      result.totalSteelLengthMeters,
    );
    expect(decoded.result.rowResults.last.baseOffsetMeters, 0.25);
    expect(decoded.result.bomItems.length, result.bomItems.length);
  });

  test('encrypted file bytes do not contain readable JSON keys', () async {
    final input = buildInput();
    final bytes = await service.encodeStructureDesign(
      title: 'Hidden Data',
      input: input,
      result: calculator.calculate(input),
      appVersion: 'test',
    );

    final text = utf8.decode(bytes, allowMalformed: true);

    expect(text, contains(wattDrawingMagic));
    expect(text, isNot(contains('siteWidthMeters')));
    expect(text, isNot(contains('frontLegHeightMeters')));
  });

  test('wrong magic header fails', () async {
    final input = buildInput();
    final bytes = await service.encodeStructureDesign(
      title: 'Bad Magic',
      input: input,
      result: calculator.calculate(input),
      appVersion: 'test',
    );
    final tampered = Uint8List.fromList(bytes)..[0] = 0x00;

    expect(
      () => service.decode(tampered),
      throwsA(isA<WattDrawingFileException>()),
    );
  });

  test('tampered encrypted payload fails authentication', () async {
    final input = buildInput();
    final bytes = await service.encodeStructureDesign(
      title: 'Tamper',
      input: input,
      result: calculator.calculate(input),
      appVersion: 'test',
    );
    final tampered = Uint8List.fromList(bytes);
    tampered[tampered.length - 1] ^= 0x7f;

    expect(
      () => service.decode(tampered),
      throwsA(isA<WattDrawingFileException>()),
    );
  });

  test('unsupported schema version fails clearly', () async {
    final input = buildInput();
    final bytes = await service.encodeStructureDesign(
      title: 'Future',
      input: input,
      result: calculator.calculate(input),
      schemaVersion: wattDrawingSchemaVersion + 1,
      appVersion: 'test',
    );

    expect(
      () => service.decode(bytes),
      throwsA(isA<WattDrawingFileException>()),
    );
  });
}
