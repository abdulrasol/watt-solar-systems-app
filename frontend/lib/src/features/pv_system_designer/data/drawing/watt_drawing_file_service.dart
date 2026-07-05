import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:solar_hub/src/core/utils/date_parser.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/bom_item.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/frame_result.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/row_frame_result.dart';
import 'package:solar_hub/src/features/pv_system_designer/domain/entities/pv_system_design_state.dart';

const wattDrawingExtension = 'wattd';
const wattDrawingMimeType = 'application/vnd.watt.drawing';
const wattDrawingMagic = 'WATTDOC';
const wattDrawingSchemaVersion = 2;
const wattDrawingDocumentTypePvSystem = 'pv_system_design';

class WattDrawingDocument {
  const WattDrawingDocument({
    required this.title,
    required this.documentType,
    required this.schemaVersion,
    required this.createdAt,
    required this.updatedAt,
    required this.appVersion,
    required this.state,
    required this.frameResult,
  });

  final String title;
  final String documentType;
  final int schemaVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String appVersion;
  final PvSystemDesignState state;
  final FrameResult frameResult;
}

class WattDrawingFileException implements Exception {
  const WattDrawingFileException(this.message);
  final String message;
  @override
  String toString() => message;
}

class WattDrawingFileService {
  WattDrawingFileService({AesGcm? algorithm, SecretKey? secretKey, DateTime Function()? now})
      : _algorithm = algorithm ?? AesGcm.with256bits(),
        _secretKey = secretKey ?? SecretKey(_documentKey),
        _now = now ?? DateTime.now;

  static final List<int> _documentKey = <int>[
    0x57, 0x61, 0x74, 0x74, 0x44, 0x72, 0x61, 0x77,
    0x2d, 0x76, 0x32, 0x2d, 0x6d, 0x65, 0x63, 0x68,
    0x2d, 0x73, 0x6f, 0x6c, 0x61, 0x72, 0x2d, 0x68,
    0x75, 0x62, 0x2d, 0x32, 0x30, 0x32, 0x36, 0x21,
  ];

  final AesGcm _algorithm;
  final SecretKey _secretKey;
  final DateTime Function() _now;

  Future<Uint8List> encodeDocument({
    required String title,
    required PvSystemDesignState state,
    required FrameResult result,
    String? appVersion,
  }) async {
    final now = _now().toUtc();
    final resolvedAppVersion = appVersion ?? await _resolveAppVersion();
    final document = WattDrawingDocument(
      title: title.trim().isEmpty ? 'PV System Design' : title.trim(),
      documentType: wattDrawingDocumentTypePvSystem,
      schemaVersion: wattDrawingSchemaVersion,
      createdAt: now,
      updatedAt: now,
      appVersion: resolvedAppVersion,
      state: state,
      frameResult: result,
    );
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
    if (documentType != wattDrawingDocumentTypePvSystem) {
      throw const WattDrawingFileException('Unsupported Watt drawing document type.');
    }
    return _documentFromJson(decoded);
  }

  Future<File> saveToAppDocuments({required String title, required Uint8List bytes}) async {
    final directory = await getApplicationDocumentsDirectory();
    final safeTitle = _safeFileName(title.trim().isEmpty ? 'pv-system-design' : title);
    final stamp = _now().toUtc().toIso8601String().replaceAll(RegExp(r'[:.]'), '-');
    final file = File('${directory.path}/$safeTitle-$stamp.$wattDrawingExtension');
    return file.writeAsBytes(bytes, flush: true);
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
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>[wattDrawingExtension],
      withData: true,
    );
    final file = picked?.files.single;
    if (file == null) return null;
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

  Map<String, dynamic> _documentToJson(WattDrawingDocument doc) {
    return <String, dynamic>{
      'schemaVersion': doc.schemaVersion,
      'documentType': doc.documentType,
      'title': doc.title,
      'createdAt': doc.createdAt.toUtc().toIso8601String(),
      'updatedAt': doc.updatedAt.toUtc().toIso8601String(),
      'appVersion': doc.appVersion,
      'pvSystemDesign': <String, dynamic>{
        'state': doc.state.toJson(),
        'frameResult': _resultToJson(doc.frameResult),
      },
    };
  }

  WattDrawingDocument _documentFromJson(Map<String, dynamic> json) {
    final pvSystem = _asMap(json['pvSystemDesign'], 'pvSystemDesign');
    return WattDrawingDocument(
      title: _asString(json['title'], 'title'),
      documentType: _asString(json['documentType'], 'documentType'),
      schemaVersion: _asInt(json['schemaVersion'], 'schemaVersion'),
      createdAt: safeParseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: safeParseDate(json['updatedAt']) ?? DateTime.now(),
      appVersion: _asString(json['appVersion'], 'appVersion'),
      state: PvSystemDesignState.fromJson(_asMap(pvSystem['state'], 'state')),
      frameResult: _resultFromJson(_asMap(pvSystem['frameResult'], 'frameResult')),
    );
  }

  Map<String, dynamic> _resultToJson(FrameResult r) {
    return <String, dynamic>{
      'idealAzimuthDegrees': r.idealAzimuthDegrees,
      'appliedAzimuthDegrees': r.appliedAzimuthDegrees,
      'idealTiltDegrees': r.idealTiltDegrees,
      'appliedTiltDegrees': r.appliedTiltDegrees,
      'isOrientationConstrained': r.isOrientationConstrained,
      'rowMode': r.rowMode.name,
      'rows': r.rows,
      'columns': r.columns,
      'panelCount': r.panelCount,
      'maxRows': r.maxRows,
      'maxColumns': r.maxColumns,
      'frameWidthMeters': r.frameWidthMeters,
      'frameSlopeLengthMeters': r.frameSlopeLengthMeters,
      'projectedRowDepthMeters': r.projectedRowDepthMeters,
      'rowSpacingMeters': r.rowSpacingMeters,
      'totalFootprintDepthMeters': r.totalFootprintDepthMeters,
      'frontLegHeightMeters': r.frontLegHeightMeters,
      'rearLegHeightMeters': r.rearLegHeightMeters,
      'minFrontLegHeightMeters': r.minFrontLegHeightMeters,
      'maxFrontLegHeightMeters': r.maxFrontLegHeightMeters,
      'minRearLegHeightMeters': r.minRearLegHeightMeters,
      'maxRearLegHeightMeters': r.maxRearLegHeightMeters,
      'railLengthMeters': r.railLengthMeters,
      'braceLengthMeters': r.braceLengthMeters,
      'supportSpacingMeters': r.supportSpacingMeters,
      'supportStationCount': r.supportStationCount,
      'totalFrontLegLengthMeters': r.totalFrontLegLengthMeters,
      'totalRearLegLengthMeters': r.totalRearLegLengthMeters,
      'totalBraceLengthMeters': r.totalBraceLengthMeters,
      'totalSteelLengthMeters': r.totalSteelLengthMeters,
      'frontLegCount': r.frontLegCount,
      'rearLegCount': r.rearLegCount,
      'anchorCount': r.anchorCount,
      'usableWidthMeters': r.usableWidthMeters,
      'usableDepthMeters': r.usableDepthMeters,
      'panelOrientation': r.panelOrientation.name,
      'rowResults': r.rowResults.map(_rowToJson).toList(),
      'isUniformLegDesign': r.isUniformLegDesign,
      'bomItems': r.bomItems.map(_bomToJson).toList(),
    };
  }

  FrameResult _resultFromJson(Map<String, dynamic> json) {
    return FrameResult(
      idealAzimuthDegrees: _asDouble(json['idealAzimuthDegrees'], 'idealAzimuthDegrees'),
      appliedAzimuthDegrees: _asDouble(json['appliedAzimuthDegrees'], 'appliedAzimuthDegrees'),
      idealTiltDegrees: _asDouble(json['idealTiltDegrees'], 'idealTiltDegrees'),
      appliedTiltDegrees: _asDouble(json['appliedTiltDegrees'], 'appliedTiltDegrees'),
      isOrientationConstrained: _asBool(json['isOrientationConstrained'], 'isOrientationConstrained'),
      rowMode: RowMode.values.firstWhere((v) => v.name == json['rowMode'], orElse: () => RowMode.independent),
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
      panelOrientation: PanelOrientation.values.firstWhere((v) => v.name == json['panelOrientation'], orElse: () => PanelOrientation.portrait),
      rowResults: (json['rowResults'] as List).map((e) => _rowFromJson(_asMap(e, 'rowResult'))).toList(),
      isUniformLegDesign: _asBool(json['isUniformLegDesign'], 'isUniformLegDesign'),
      bomItems: (json['bomItems'] as List).map((e) => _bomFromJson(_asMap(e, 'bomItem'))).toList(),
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
    return safe.isEmpty ? 'pv-system-design' : safe;
  }

  Uint8List _uint32(int value) {
    final data = ByteData(4)..setUint32(0, value, Endian.big);
    return data.buffer.asUint8List();
  }

  int _readUint32(Uint8List bytes, int offset) {
    return ByteData.sublistView(bytes, offset, offset + 4).getUint32(0, Endian.big);
  }

  Map<String, dynamic> _asMap(Object? value, String field) {
    if (value is Map<String, dynamic>) return value;
    throw WattDrawingFileException('Invalid Watt drawing field: $field.');
  }

  String _asString(Object? value, String field) {
    if (value is String) return value;
    throw WattDrawingFileException('Invalid Watt drawing field: $field.');
  }

  double _asDouble(Object? value, String field) {
    if (value is num) return value.toDouble();
    throw WattDrawingFileException('Invalid Watt drawing field: $field.');
  }

  int _asInt(Object? value, String field) {
    if (value is int) return value;
    throw WattDrawingFileException('Invalid Watt drawing field: $field.');
  }

  bool _asBool(Object? value, String field) {
    if (value is bool) return value;
    throw WattDrawingFileException('Invalid Watt drawing field: $field.');
  }
}
