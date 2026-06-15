import 'package:flutter/material.dart';
import 'package:solar_hub/src/features/structure_design/domain/entities/structure_design_input.dart';

@immutable
class SiteProfile {
  const SiteProfile({
    this.locationName = '',
    this.latitude = 24.7136,
    this.longitude = 46.6753,
    this.roofWidthM = 10.0,
    this.roofLengthM = 8.0,
    this.roofPitchDeg = 0.0,
    this.roofAzimuthDeg = 180.0,
    this.mountType = MountType.ground,
    this.wallSetbackM = 0.5,
    this.frontClearanceM = 0.5,
    this.rearClearanceM = 0.5,
    this.sideClearanceM = 0.5,
    this.frontLegClearanceM = 0.3,
    this.interRowGapM = 0.5,
  });

  final String locationName;
  final double latitude;
  final double longitude;
  final double roofWidthM;
  final double roofLengthM;
  final double roofPitchDeg;
  final double roofAzimuthDeg;
  final MountType mountType;
  final double wallSetbackM;
  final double frontClearanceM;
  final double rearClearanceM;
  final double sideClearanceM;
  final double frontLegClearanceM;
  final double interRowGapM;

  SiteProfile copyWith({
    String? locationName,
    double? latitude,
    double? longitude,
    double? roofWidthM,
    double? roofLengthM,
    double? roofPitchDeg,
    double? roofAzimuthDeg,
    MountType? mountType,
    double? wallSetbackM,
    double? frontClearanceM,
    double? rearClearanceM,
    double? sideClearanceM,
    double? frontLegClearanceM,
    double? interRowGapM,
  }) {
    return SiteProfile(
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      roofWidthM: roofWidthM ?? this.roofWidthM,
      roofLengthM: roofLengthM ?? this.roofLengthM,
      roofPitchDeg: roofPitchDeg ?? this.roofPitchDeg,
      roofAzimuthDeg: roofAzimuthDeg ?? this.roofAzimuthDeg,
      mountType: mountType ?? this.mountType,
      wallSetbackM: wallSetbackM ?? this.wallSetbackM,
      frontClearanceM: frontClearanceM ?? this.frontClearanceM,
      rearClearanceM: rearClearanceM ?? this.rearClearanceM,
      sideClearanceM: sideClearanceM ?? this.sideClearanceM,
      frontLegClearanceM: frontLegClearanceM ?? this.frontLegClearanceM,
      interRowGapM: interRowGapM ?? this.interRowGapM,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationName': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'roofWidthM': roofWidthM,
      'roofLengthM': roofLengthM,
      'roofPitchDeg': roofPitchDeg,
      'roofAzimuthDeg': roofAzimuthDeg,
      'mountType': mountType.name,
      'wallSetbackM': wallSetbackM,
      'frontClearanceM': frontClearanceM,
      'rearClearanceM': rearClearanceM,
      'sideClearanceM': sideClearanceM,
      'frontLegClearanceM': frontLegClearanceM,
      'interRowGapM': interRowGapM,
    };
  }

  factory SiteProfile.fromJson(Map<String, dynamic> json) {
    return SiteProfile(
      locationName: json['locationName'] as String? ?? '',
      latitude: (json['latitude'] as num? ?? 24.7136).toDouble(),
      longitude: (json['longitude'] as num? ?? 46.6753).toDouble(),
      roofWidthM: (json['roofWidthM'] as num? ?? 10.0).toDouble(),
      roofLengthM: (json['roofLengthM'] as num? ?? 8.0).toDouble(),
      roofPitchDeg: (json['roofPitchDeg'] as num? ?? 0.0).toDouble(),
      roofAzimuthDeg: (json['roofAzimuthDeg'] as num? ?? 180.0).toDouble(),
      mountType: MountType.values.firstWhere(
        (e) => e.name == json['mountType'],
        orElse: () => MountType.ground,
      ),
      wallSetbackM: (json['wallSetbackM'] as num? ?? 0.5).toDouble(),
      frontClearanceM: (json['frontClearanceM'] as num? ?? 0.5).toDouble(),
      rearClearanceM: (json['rearClearanceM'] as num? ?? 0.5).toDouble(),
      sideClearanceM: (json['sideClearanceM'] as num? ?? 0.5).toDouble(),
      frontLegClearanceM: (json['frontLegClearanceM'] as num? ?? 0.3).toDouble(),
      interRowGapM: (json['interRowGapM'] as num? ?? 0.5).toDouble(),
    );
  }
}
