import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:watt/src/features/structure_design/domain/entities/bom_item.dart';
import 'package:watt/src/features/structure_design/domain/entities/drawing/watt_drawing_document.dart';
import 'package:watt/src/features/structure_design/domain/entities/frame_result.dart';
import 'package:watt/src/features/structure_design/domain/entities/panel_spec.dart';
import 'package:watt/src/features/structure_design/domain/entities/row_frame_result.dart';
import 'package:watt/src/features/structure_design/domain/entities/structure_design_input.dart';

class WattDrawingFileService {
  WattDrawingFileService({AesGcm? algorithm, SecretKey? secretKey, DateTime Function()? now})
    : _algorithm = algorithm ?? AesGcm.with256bits(),
      _secretKey = secretKey ?? SecretKey(_documentKey),
      _now = now ?? DateTime.now;

  static final List<int> _documentKey = <int>[
    0x57,
    0x61,
    0x74,
    0x74,
    0x44,
    0x72,
    0x61,
    0x77,
    0x2d,
    0x76,
    0x31,
    0x2d,
    0x6d,
    0x65,
    0x63,
    0x68,
    0x2d,
    0x73,
    0x6f,
    0x6c,
    0x61,
    0x72,
    0x2d,
    0x68,
    0x75,
    0x62,
    0x2d,
    0x32,
    0x30,
    0x32,
    0x36,
    0x21,
  ];

  final AesGcm _algorithm;
  final SecretKey _secretKey;
  final DateTime Function() _now;

  Future<Uint8List> encodeStructureDesign({
    required String title,
    required StructureDesignInput input,
    required FrameResult result,
    int schemaVersion = wattDrawingSchemaVersion,
    String? appVersion,
  }) async {
    final now = _now().toUtc();
    final resolvedAppVersion = appVersion ?? await _resolveAppVersion();
    return encodeDocument(
      WattDrawingDocument(
        title: title.trim().isEmpty ? 'Structure Design' : title.trim(),
        documentType: wattDrawingDocumentTypeStructureDesign,
        schemaVersion: schemaVersion,
        createdAt: now,
        updatedAt: now,
        appVersion: resolvedAppVersion,
        input: input,
        result: result,
      ),
    );
  }

  Future<Uint8List> encodeDocument(WattDrawingDocument document) async {
    final payload = utf8.encode(jsonEncode(_documentToJson(document)));
    final secretBox = await _algorithm.encrypt(payload, secretKey: _secretKey);
    return _packEnvelope(secretBox);
  }

  Future<WattDrawingDocument> decode(Uint8List bytes) async {
    final secretBox = _unpackEnvelope(bytes);
    final decrypted = await _decrypt(secretBox);
    final decoded = jsonDecode(utf8.decode(decrypted));
    if (decoded is! Map<String, dynamic>) {
      throw const WattDrawingFileException('Invalid Watt drawing document.');
    }
    final schemaVersion = decoded['schemaVersion'];
    if (schemaVersion != wattDrawingSchemaVersion) {
      throw const WattDrawingFileException('Unsupported Watt drawing schema version.');
    }
    final documentType = decoded['documentType'];
    if (documentType != wattDrawingDocumentTypeStructureDesign) {
      throw const WattDrawingFileException('Unsupported Watt drawing document type.');
    }
    return _documentFromJson(decoded);
  }

  Future<File> saveToAppDocuments({required String title, required Uint8List bytes}) async {
    final directory = await getApplicationDocumentsDirectory();
    final safeTitle = _safeFileName(title.trim().isEmpty ? 'structure-design' : title);
    final stamp = _now().toUtc().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
    final file = File('${directory.path}/$safeTitle-$stamp.$wattDrawingExtension');
    return file.writeAsBytes(bytes, flush: true);
  }

  Future<File> saveStructureDesignToAppDocuments({required String title, required StructureDesignInput input, required FrameResult result}) async {
    final bytes = await encodeStructureDesign(title: title, input: input, result: result);
    return saveToAppDocuments(title: title, bytes: bytes);
  }

  Future<void> shareWattDrawing(File file, {String? subject}) {
    return SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(file.path, mimeType: wattDrawingMimeType, name: file.uri.pathSegments.last)],
        subject: subject,
        title: subject,
      ),
    );
  }

  Future<WattDrawingDocument?> pickAndDecode() async {
    final picked = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: const <String>[wattDrawingExtension], withData: true);
    final file = picked?.files.single;
    if (file == null) {
      return null;
    }
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    return decode(Uint8List.fromList(bytes));
  }

  Future<List<int>> _decrypt(SecretBox secretBox) async {
    try {
      return await _algorithm.decrypt(secretBox, secretKey: _secretKey);
    } on SecretBoxAuthenticationError {
      throw const WattDrawingFileException('Watt drawing authentication failed.');
    } on FormatException {
      throw const WattDrawingFileException('Invalid Watt drawing document.');
    }
  }

  Uint8List _packEnvelope(SecretBox secretBox) {
    final magic = ascii.encode(wattDrawingMagic);
    final cipherText = secretBox.cipherText;
    final nonce = secretBox.nonce;
    final mac = secretBox.mac.bytes;
    final builder = BytesBuilder(copy: false)
      ..add(magic)
      ..add(<int>[wattDrawingSchemaVersion, nonce.length])
      ..add(nonce)
      ..add(<int>[mac.length])
      ..add(mac)
      ..add(_uint32(cipherText.length))
      ..add(cipherText);
    return builder.toBytes();
  }

  SecretBox _unpackEnvelope(Uint8List bytes) {
    final magic = ascii.encode(wattDrawingMagic);
    if (bytes.length < magic.length + 8) {
      throw const WattDrawingFileException('Invalid Watt drawing file.');
    }
    for (var i = 0; i < magic.length; i++) {
      if (bytes[i] != magic[i]) {
        throw const WattDrawingFileException('Invalid Watt drawing file.');
      }
    }
    var offset = magic.length;
    final envelopeVersion = bytes[offset++];
    if (envelopeVersion != wattDrawingSchemaVersion) {
      throw const WattDrawingFileException('Unsupported Watt drawing schema version.');
    }
    final nonceLength = bytes[offset++];
    if (bytes.length < offset + nonceLength + 1) {
      throw const WattDrawingFileException('Invalid Watt drawing file.');
    }
    final nonce = bytes.sublist(offset, offset + nonceLength);
    offset += nonceLength;
    final macLength = bytes[offset++];
    if (bytes.length < offset + macLength + 4) {
      throw const WattDrawingFileException('Invalid Watt drawing file.');
    }
    final mac = bytes.sublist(offset, offset + macLength);
    offset += macLength;
    final cipherLength = _readUint32(bytes, offset);
    offset += 4;
    if (bytes.length != offset + cipherLength) {
      throw const WattDrawingFileException('Invalid Watt drawing file.');
    }
    final cipherText = bytes.sublist(offset, offset + cipherLength);
    return SecretBox(cipherText, nonce: nonce, mac: Mac(mac));
  }

  Map<String, dynamic> _documentToJson(WattDrawingDocument document) {
    return <String, dynamic>{
      'schemaVersion': document.schemaVersion,
      'documentType': document.documentType,
      'title': document.title,
      'createdAt': document.createdAt.toUtc().toIso8601String(),
      'updatedAt': document.updatedAt.toUtc().toIso8601String(),
      'appVersion': document.appVersion,
      'structureDesign': <String, dynamic>{'input': _inputToJson(document.input), 'result': _resultToJson(document.result)},
    };
  }

  WattDrawingDocument _documentFromJson(Map<String, dynamic> json) {
    final structure = _asMap(json['structureDesign'], 'structureDesign');
    return WattDrawingDocument(
      title: _asString(json['title'], 'title'),
      documentType: _asString(json['documentType'], 'documentType'),
      schemaVersion: _asInt(json['schemaVersion'], 'schemaVersion'),
      createdAt: DateTime.parse(_asString(json['createdAt'], 'createdAt')),
      updatedAt: DateTime.parse(_asString(json['updatedAt'], 'updatedAt')),
      appVersion: _asString(json['appVersion'], 'appVersion'),
      input: _inputFromJson(_asMap(structure['input'], 'input')),
      result: _resultFromJson(_asMap(structure['result'], 'result')),
    );
  }

  Map<String, dynamic> _inputToJson(StructureDesignInput input) {
    return <String, dynamic>{
      'siteWidthMeters': input.siteWidthMeters,
      'siteDepthMeters': input.siteDepthMeters,
      'latitude': input.latitude,
      'facingPreference': input.facingPreference.name,
      'mountType': input.mountType.name,
      'frontClearanceMeters': input.frontClearanceMeters,
      'rearClearanceMeters': input.rearClearanceMeters,
      'sideClearanceMeters': input.sideClearanceMeters,
      'frontLegClearanceMeters': input.frontLegClearanceMeters,
      'interRowGapMeters': input.interRowGapMeters,
      'panelSpec': _panelToJson(input.panelSpec),
      'rowMode': input.rowMode.name,
      'rowBaseOffsetsMeters': input.rowBaseOffsetsMeters,
      'targetPanelCount': input.targetPanelCount,
      'manualRows': input.manualRows,
      'manualColumns': input.manualColumns,
    };
  }

  StructureDesignInput _inputFromJson(Map<String, dynamic> json) {
    return StructureDesignInput(
      siteWidthMeters: _asDouble(json['siteWidthMeters'], 'siteWidthMeters'),
      siteDepthMeters: _asDouble(json['siteDepthMeters'], 'siteDepthMeters'),
      latitude: _asDouble(json['latitude'], 'latitude'),
      facingPreference: _enumByName(FacingDirectionPreference.values, json['facingPreference'], 'facingPreference'),
      mountType: _enumByName(MountType.values, json['mountType'], 'mountType'),
      frontClearanceMeters: _asDouble(json['frontClearanceMeters'], 'frontClearanceMeters'),
      rearClearanceMeters: _asDouble(json['rearClearanceMeters'], 'rearClearanceMeters'),
      sideClearanceMeters: _asDouble(json['sideClearanceMeters'], 'sideClearanceMeters'),
      frontLegClearanceMeters: _asDouble(json['frontLegClearanceMeters'], 'frontLegClearanceMeters'),
      interRowGapMeters: _asDouble(json['interRowGapMeters'], 'interRowGapMeters'),
      panelSpec: _panelFromJson(_asMap(json['panelSpec'], 'panelSpec')),
      rowMode: _enumByName(RowMode.values, json['rowMode'], 'rowMode'),
      rowBaseOffsetsMeters: _doubleList(json['rowBaseOffsetsMeters'], 'rowBaseOffsetsMeters'),
      targetPanelCount: _asNullableInt(json['targetPanelCount']),
      manualRows: _asNullableInt(json['manualRows']),
      manualColumns: _asNullableInt(json['manualColumns']),
    );
  }

  Map<String, dynamic> _panelToJson(PanelSpec panel) {
    return <String, dynamic>{
      'lengthMeters': panel.lengthMeters,
      'widthMeters': panel.widthMeters,
      'thicknessMeters': panel.thicknessMeters,
      'orientation': panel.orientation.name,
      'horizontalGapMeters': panel.horizontalGapMeters,
      'verticalGapMeters': panel.verticalGapMeters,
    };
  }

  PanelSpec _panelFromJson(Map<String, dynamic> json) {
    return PanelSpec(
      lengthMeters: _asDouble(json['lengthMeters'], 'lengthMeters'),
      widthMeters: _asDouble(json['widthMeters'], 'widthMeters'),
      thicknessMeters: _asDouble(json['thicknessMeters'], 'thicknessMeters'),
      orientation: _enumByName(PanelOrientation.values, json['orientation'], 'orientation'),
      horizontalGapMeters: _asDouble(json['horizontalGapMeters'], 'horizontalGapMeters'),
      verticalGapMeters: _asDouble(json['verticalGapMeters'], 'verticalGapMeters'),
    );
  }

  Map<String, dynamic> _resultToJson(FrameResult result) {
    return <String, dynamic>{
      'idealAzimuthDegrees': result.idealAzimuthDegrees,
      'appliedAzimuthDegrees': result.appliedAzimuthDegrees,
      'idealTiltDegrees': result.idealTiltDegrees,
      'appliedTiltDegrees': result.appliedTiltDegrees,
      'isOrientationConstrained': result.isOrientationConstrained,
      'rowMode': result.rowMode.name,
      'rows': result.rows,
      'columns': result.columns,
      'panelCount': result.panelCount,
      'maxRows': result.maxRows,
      'maxColumns': result.maxColumns,
      'frameWidthMeters': result.frameWidthMeters,
      'frameSlopeLengthMeters': result.frameSlopeLengthMeters,
      'projectedRowDepthMeters': result.projectedRowDepthMeters,
      'rowSpacingMeters': result.rowSpacingMeters,
      'totalFootprintDepthMeters': result.totalFootprintDepthMeters,
      'frontLegHeightMeters': result.frontLegHeightMeters,
      'rearLegHeightMeters': result.rearLegHeightMeters,
      'minFrontLegHeightMeters': result.minFrontLegHeightMeters,
      'maxFrontLegHeightMeters': result.maxFrontLegHeightMeters,
      'minRearLegHeightMeters': result.minRearLegHeightMeters,
      'maxRearLegHeightMeters': result.maxRearLegHeightMeters,
      'railLengthMeters': result.railLengthMeters,
      'braceLengthMeters': result.braceLengthMeters,
      'supportSpacingMeters': result.supportSpacingMeters,
      'supportStationCount': result.supportStationCount,
      'totalFrontLegLengthMeters': result.totalFrontLegLengthMeters,
      'totalRearLegLengthMeters': result.totalRearLegLengthMeters,
      'totalBraceLengthMeters': result.totalBraceLengthMeters,
      'totalSteelLengthMeters': result.totalSteelLengthMeters,
      'frontLegCount': result.frontLegCount,
      'rearLegCount': result.rearLegCount,
      'anchorCount': result.anchorCount,
      'usableWidthMeters': result.usableWidthMeters,
      'usableDepthMeters': result.usableDepthMeters,
      'panelOrientation': result.panelOrientation.name,
      'rowResults': result.rowResults.map(_rowToJson).toList(),
      'isUniformLegDesign': result.isUniformLegDesign,
      'bomItems': result.bomItems.map(_bomToJson).toList(),
    };
  }

  FrameResult _resultFromJson(Map<String, dynamic> json) {
    return FrameResult(
      idealAzimuthDegrees: _asDouble(json['idealAzimuthDegrees'], 'idealAzimuthDegrees'),
      appliedAzimuthDegrees: _asDouble(json['appliedAzimuthDegrees'], 'appliedAzimuthDegrees'),
      idealTiltDegrees: _asDouble(json['idealTiltDegrees'], 'idealTiltDegrees'),
      appliedTiltDegrees: _asDouble(json['appliedTiltDegrees'], 'appliedTiltDegrees'),
      isOrientationConstrained: _asBool(json['isOrientationConstrained'], 'isOrientationConstrained'),
      rowMode: _enumByName(RowMode.values, json['rowMode'], 'rowMode'),
      rows: _asInt(json['rows'], 'rows'),
      columns: _asInt(json['columns'], 'columns'),
      panelCount: _asInt(json['panelCount'], 'panelCount'),
      maxRows: _asInt(json['maxRows'], 'maxRows'),
      maxColumns: _asInt(json['maxColumns'], 'maxColumns'),
      frameWidthMeters: _asDouble(json['frameWidthMeters'], 'frameWidthMeters'),
      frameSlopeLengthMeters: _asDouble(json['frameSlopeLengthMeters'], 'frameSlopeLengthMeters'),
      projectedRowDepthMeters: _asDouble(json['projectedRowDepthMeters'], 'projectedRowDepthMeters'),
      rowSpacingMeters: _asDouble(json['rowSpacingMeters'], 'rowSpacingMeters'),
      totalFootprintDepthMeters: _asDouble(json['totalFootprintDepthMeters'], 'totalFootprintDepthMeters'),
      frontLegHeightMeters: _asDouble(json['frontLegHeightMeters'], 'frontLegHeightMeters'),
      rearLegHeightMeters: _asDouble(json['rearLegHeightMeters'], 'rearLegHeightMeters'),
      minFrontLegHeightMeters: _asDouble(json['minFrontLegHeightMeters'], 'minFrontLegHeightMeters'),
      maxFrontLegHeightMeters: _asDouble(json['maxFrontLegHeightMeters'], 'maxFrontLegHeightMeters'),
      minRearLegHeightMeters: _asDouble(json['minRearLegHeightMeters'], 'minRearLegHeightMeters'),
      maxRearLegHeightMeters: _asDouble(json['maxRearLegHeightMeters'], 'maxRearLegHeightMeters'),
      railLengthMeters: _asDouble(json['railLengthMeters'], 'railLengthMeters'),
      braceLengthMeters: _asDouble(json['braceLengthMeters'], 'braceLengthMeters'),
      supportSpacingMeters: _asDouble(json['supportSpacingMeters'], 'supportSpacingMeters'),
      supportStationCount: _asInt(json['supportStationCount'], 'supportStationCount'),
      totalFrontLegLengthMeters: _asDouble(json['totalFrontLegLengthMeters'], 'totalFrontLegLengthMeters'),
      totalRearLegLengthMeters: _asDouble(json['totalRearLegLengthMeters'], 'totalRearLegLengthMeters'),
      totalBraceLengthMeters: _asDouble(json['totalBraceLengthMeters'], 'totalBraceLengthMeters'),
      totalSteelLengthMeters: _asDouble(json['totalSteelLengthMeters'], 'totalSteelLengthMeters'),
      frontLegCount: _asInt(json['frontLegCount'], 'frontLegCount'),
      rearLegCount: _asInt(json['rearLegCount'], 'rearLegCount'),
      anchorCount: _asInt(json['anchorCount'], 'anchorCount'),
      usableWidthMeters: _asDouble(json['usableWidthMeters'], 'usableWidthMeters'),
      usableDepthMeters: _asDouble(json['usableDepthMeters'], 'usableDepthMeters'),
      panelOrientation: _enumByName(PanelOrientation.values, json['panelOrientation'], 'panelOrientation'),
      rowResults: _mapList(json['rowResults'], 'rowResults').map(_rowFromJson).toList(),
      isUniformLegDesign: _asBool(json['isUniformLegDesign'], 'isUniformLegDesign'),
      bomItems: _mapList(json['bomItems'], 'bomItems').map(_bomFromJson).toList(),
    );
  }

  Map<String, dynamic> _rowToJson(RowFrameResult row) {
    return <String, dynamic>{
      'rowIndex': row.rowIndex,
      'baseOffsetMeters': row.baseOffsetMeters,
      'frontLegHeightMeters': row.frontLegHeightMeters,
      'rearLegHeightMeters': row.rearLegHeightMeters,
      'rowSpacingMeters': row.rowSpacingMeters,
      'localFootprintDepthMeters': row.localFootprintDepthMeters,
    };
  }

  RowFrameResult _rowFromJson(Map<String, dynamic> json) {
    return RowFrameResult(
      rowIndex: _asInt(json['rowIndex'], 'rowIndex'),
      baseOffsetMeters: _asDouble(json['baseOffsetMeters'], 'baseOffsetMeters'),
      frontLegHeightMeters: _asDouble(json['frontLegHeightMeters'], 'frontLegHeightMeters'),
      rearLegHeightMeters: _asDouble(json['rearLegHeightMeters'], 'rearLegHeightMeters'),
      rowSpacingMeters: _asDouble(json['rowSpacingMeters'], 'rowSpacingMeters'),
      localFootprintDepthMeters: _asDouble(json['localFootprintDepthMeters'], 'localFootprintDepthMeters'),
    );
  }

  Map<String, dynamic> _bomToJson(BomItem item) {
    return <String, dynamic>{'name': item.name, 'unit': item.unit, 'quantity': item.quantity, 'note': item.note};
  }

  BomItem _bomFromJson(Map<String, dynamic> json) {
    return BomItem(
      name: _asString(json['name'], 'name'),
      unit: _asString(json['unit'], 'unit'),
      quantity: _asDouble(json['quantity'], 'quantity'),
      note: json['note'] == null ? null : _asString(json['note'], 'note'),
    );
  }

  Future<String> _resolveAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return '${info.version}+${info.buildNumber}';
    } catch (_) {
      return 'unknown';
    }
  }

  String _safeFileName(String value) {
    final safe = value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9._-]+'), '-').replaceAll(RegExp(r'-+'), '-').replaceAll(RegExp(r'^-|-$'), '');
    return safe.isEmpty ? 'structure-design' : safe;
  }

  Uint8List _uint32(int value) {
    final data = ByteData(4)..setUint32(0, value, Endian.big);
    return data.buffer.asUint8List();
  }

  int _readUint32(Uint8List bytes, int offset) {
    return ByteData.sublistView(bytes, offset, offset + 4).getUint32(0, Endian.big);
  }

  Map<String, dynamic> _asMap(Object? value, String field) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    throw WattDrawingFileException('Invalid Watt drawing field: $field.');
  }

  List<Map<String, dynamic>> _mapList(Object? value, String field) {
    if (value is List) {
      return value.map((item) => _asMap(item, field)).toList();
    }
    throw WattDrawingFileException('Invalid Watt drawing field: $field.');
  }

  List<double> _doubleList(Object? value, String field) {
    if (value is List) {
      return value.map((item) => _asDouble(item, field)).toList();
    }
    throw WattDrawingFileException('Invalid Watt drawing field: $field.');
  }

  String _asString(Object? value, String field) {
    if (value is String) {
      return value;
    }
    throw WattDrawingFileException('Invalid Watt drawing field: $field.');
  }

  double _asDouble(Object? value, String field) {
    if (value is num) {
      return value.toDouble();
    }
    throw WattDrawingFileException('Invalid Watt drawing field: $field.');
  }

  int _asInt(Object? value, String field) {
    if (value is int) {
      return value;
    }
    throw WattDrawingFileException('Invalid Watt drawing field: $field.');
  }

  int? _asNullableInt(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    throw const WattDrawingFileException('Invalid Watt drawing integer field.');
  }

  bool _asBool(Object? value, String field) {
    if (value is bool) {
      return value;
    }
    throw WattDrawingFileException('Invalid Watt drawing field: $field.');
  }

  T _enumByName<T extends Enum>(List<T> values, Object? value, String field) {
    if (value is String) {
      for (final candidate in values) {
        if (candidate.name == value) {
          return candidate;
        }
      }
    }
    throw WattDrawingFileException('Invalid Watt drawing enum field: $field.');
  }
}
