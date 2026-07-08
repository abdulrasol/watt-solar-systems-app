class OfferRequestModel {
  final String id;
  final String? userId; // 'user' in JSON
  final String title;
  final double pvTotal; // 'pv' in JSON
  final double batteryTotal; // 'battery' in JSON
  final double inverterTotal; // 'inverter' in JSON
  final String? notes;
  final RequestSpecs specs;
  final String status;
  final DateTime createdAt;

  OfferRequestModel({
    required this.id,
    this.userId,
    this.title = 'Solar System Request',
    required this.pvTotal,
    required this.batteryTotal,
    required this.inverterTotal,
    this.notes,
    required this.specs,
    this.status = 'open',
    required this.createdAt,
  });

  factory OfferRequestModel.fromJson(Map<String, dynamic> json) {
    return OfferRequestModel(
      id: json['id'] ?? '',
      userId: json['user'] ?? json['user_id'],
      title: json['title'] ?? 'Solar System Request',
      pvTotal: (json['pv'] as num?)?.toDouble() ?? 0.0,
      batteryTotal: (json['battery'] as num?)?.toDouble() ?? 0.0,
      inverterTotal: (json['inverter'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
      specs: RequestSpecs.fromJson(json['specs'] ?? {}),
      status: json['status'] ?? 'open',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId, // DB column
      'title': title,
      'pv_total': pvTotal, // DB column
      'battery_total': batteryTotal, // DB column
      'inverter_total': inverterTotal, // DB column
      'notes': notes,
      'specs': specs.toJson(), // DB column jsonb
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class RequestSpecs {
  final PanelSpecs panels;
  final BatterySpecs battery;
  final InverterSpecs inverter;

  RequestSpecs({required this.panels, required this.battery, required this.inverter});

  factory RequestSpecs.fromJson(Map<String, dynamic> json) {
    return RequestSpecs(
      panels: PanelSpecs.fromJson(json['panels'] ?? {}),
      battery: BatterySpecs.fromJson(json['battery'] ?? {}),
      inverter: InverterSpecs.fromJson(json['inverter'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'panels': panels.toJson(), 'battery': battery.toJson(), 'inverter': inverter.toJson()};
  }
}

class PanelSpecs {
  final int count;
  final int capacity;
  final String? note;

  PanelSpecs({this.count = 0, this.capacity = 0, this.note});

  factory PanelSpecs.fromJson(Map<String, dynamic> json) {
    return PanelSpecs(count: json['count'] ?? 0, capacity: json['capacity'] ?? 0, note: json['note']);
  }

  Map<String, dynamic> toJson() => {'count': count, 'capacity': capacity, 'note': note};
}

class BatterySpecs {
  final int count;
  final double capacity;
  final String? type; // 'Lithium', 'Gel', etc.
  final String? voltageType; // 'LV', 'HV'
  final String? note;
  final double systemVoltage;

  BatterySpecs({this.count = 0, this.capacity = 0.0, this.type, this.voltageType, this.note, this.systemVoltage = 0.0});

  factory BatterySpecs.fromJson(Map<String, dynamic> json) {
    return BatterySpecs(
      count: json['count'] ?? 0,
      capacity: (json['capacity'] as num?)?.toDouble() ?? 0.0,
      type: json['type'],
      voltageType: json['voltage_type'],
      note: json['note'],
      systemVoltage: (json['system_voltage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'count': count,
    'capacity': capacity,
    'type': type,
    'voltage_type': voltageType,
    'note': note,
    'system_voltage': systemVoltage,
  };
}

class InverterSpecs {
  final int count;
  final double capacity;
  final String? note;
  final String? voltageType; // 'LV', 'HV'
  final String? type; // 'Hybrid', 'On-Grid', etc.
  final String? phase; // 'Single', 'Three'

  InverterSpecs({this.count = 0, this.capacity = 0.0, this.note, this.voltageType, this.type, this.phase});

  factory InverterSpecs.fromJson(Map<String, dynamic> json) {
    return InverterSpecs(
      count: json['count'] ?? 0,
      capacity: (json['capacity'] as num?)?.toDouble() ?? 0.0,
      note: json['note'],
      voltageType: json['voltage_type'],
      type: json['type'],
      phase: json['phase'],
    );
  }

  Map<String, dynamic> toJson() => {'count': count, 'capacity': capacity, 'note': note, 'voltage_type': voltageType, 'type': type, 'phase': phase};
}
