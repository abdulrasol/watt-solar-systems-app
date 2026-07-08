import 'package:watt/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:watt/src/features/structure_design/domain/entities/structure_design_input.dart';

const wattDrawingExtension = 'wattd';
const wattDrawingMimeType = 'application/vnd.watt.drawing';
const wattDrawingMagic = 'WATTDOC';
const wattDrawingSchemaVersion = 1;
const wattDrawingDocumentTypeStructureDesign = 'structure_design';

class WattDrawingDocument {
  const WattDrawingDocument({
    required this.title,
    required this.documentType,
    required this.schemaVersion,
    required this.createdAt,
    required this.updatedAt,
    required this.appVersion,
    required this.input,
    required this.result,
  });

  final String title;
  final String documentType;
  final int schemaVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String appVersion;
  final StructureDesignInput input;
  final FrameResult result;
}

class WattDrawingFileException implements Exception {
  const WattDrawingFileException(this.message);

  final String message;

  @override
  String toString() => message;
}
