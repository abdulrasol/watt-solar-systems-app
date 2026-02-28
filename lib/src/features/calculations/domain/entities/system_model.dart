import 'package:solar_hub/src/core/enums/system_status.dart';

class SystemModel {
  final String id;
  final String? ownerId;
  final String? installedByCompanyId;
  final SystemStatus verificationStatus;
  final String? systemName;
  final String? locationCoordinates; 
  final double? totalCapacityKw;
  final String? imageUrl;
  final Map<String, dynamic> specs; 
  final String? notes;
  final DateTime? installDate;
  final DateTime? createdAt;

  final String userName;
  final String installer;

  SystemModel({
    required this.id,
    this.ownerId,
    this.installedByCompanyId,
    this.verificationStatus = SystemStatus.pending_verification,
    this.systemName,
    this.locationCoordinates, 
    this.totalCapacityKw,
    this.imageUrl,
    this.specs = const {},
    this.notes,
    this.installDate,
    this.createdAt,
    this.userName = '',
    this.installer = '',
  });

  factory SystemModel.fromJson(Map<String, dynamic> json) {
    final specs = json['specs'] as Map<String, dynamic>? ?? {};
    if (json['pv'] != null) specs['panels'] = json['pv'];
    if (json['battery'] != null) specs['batteries'] = json['battery'];
    if (json['inverter'] != null) specs['inverter'] = json['inverter'];

    return SystemModel(
      id: json['id'] as String,
      ownerId: json['user_id'] as String?,
      installedByCompanyId: json['installed_by'] as String?,
      verificationStatus: SystemStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['company_status'] == 'accepted' ? 'verified' : 'pending_verification'),
        orElse: () => SystemStatus.pending_verification,
      ),
      systemName: json['notes'] != null ? (json['notes'] as String).split('\n').first : 'System',
      locationCoordinates: json['lat'] != null ? "${json['lat']}, ${json['lan']}" : null,
      totalCapacityKw: (json['pv']?['capacity'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String?,
      specs: specs,
      notes: json['notes'] as String?,
      installDate: json['installed_at'] != null ? DateTime.tryParse(json['installed_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      userName: json['user_name'] as String? ?? '',
      installer: json['installer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'installed_by_company_id': installedByCompanyId,
      'verification_status': verificationStatus.toString().split('.').last,
      'system_name': systemName,
      'location_coordinates': locationCoordinates,
      'total_capacity_kw': totalCapacityKw,
      'image_url': imageUrl,
      'specs': specs,
      'notes': notes,
      'installation_date': installDate?.toIso8601String(),
    };
  }

  String get inverterBrand => specs['inverter']?['brand'] ?? specs['inverters']?['brand'] ?? 'N/A';
  String get inverterSize => specs['inverter']?['power']?.toString() ?? specs['inverters']?['capacity']?.toString() ?? '0';
  String get inverterType => specs['inverter']?['type'] ?? specs['inverters']?['type'] ?? 'N/A';
  String get inverterNotes => specs['inverter']?['notes'] ?? specs['inverters']?['note'] ?? '';

  int get panelCount => specs['panel']?['count'] ?? specs['panels']?['count'] ?? 0;
  String get panelBrand => specs['panel']?['brand'] ?? specs['panels']?['brand'] ?? 'N/A';
  double get panelPower => (specs['panel']?['power'] as num?)?.toDouble() ?? (specs['panels']?['capacity'] as num?)?.toDouble() ?? 0.0;
  String get panelNotes => specs['panel']?['notes'] ?? specs['panels']?['note'] ?? '';

  double get batteryAh =>
      (specs['battery']?['ah'] as num?)?.toDouble() ??
      (specs['battery']?['capacity'] as num?)?.toDouble() ??
      (specs['batteries']?['capacity'] as num?)?.toDouble() ??
      0.0;
  String get batteryBrand => specs['battery']?['brand'] ?? specs['batteries']?['brand'] ?? 'N/A';
  double get batteryVoltage => (specs['battery']?['voltage'] as num?)?.toDouble() ?? (specs['batteries']?['voltage'] as num?)?.toDouble() ?? 0.0;
  int get batteryCount => specs['battery']?['count'] ?? specs['batteries']?['count'] ?? 0;
  String get batteryNotes => specs['battery']?['notes'] ?? specs['batteries']?['note'] ?? '';
}
