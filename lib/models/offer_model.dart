class OfferModel {
  final String id;
  final String? requestId;
  final String? companyId;
  final OfferPvSpecs pvSpecs; // 'pv' in JSON
  final OfferBatterySpecs batterySpecs; // 'battery' in JSON
  final OfferInverterSpecs inverterSpecs; // 'inverter' in JSON
  final List<String> involves; // 'involves' in JSON
  final String? notes;
  final double price;
  final String status;
  final DateTime? expiresAt;
  final DateTime createdAt;

  OfferModel({
    required this.id,
    this.requestId,
    this.companyId,
    required this.pvSpecs,
    required this.batterySpecs,
    required this.inverterSpecs,
    this.involves = const [],
    this.notes,
    required this.price,
    this.status = 'pending',
    this.expiresAt,
    required this.createdAt,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] ?? '',
      requestId: json['request'] ?? json['request_id'],
      companyId: json['company'] ?? json['company_id'],
      pvSpecs: OfferPvSpecs.fromJson(json['pv'] ?? json['pv_specs'] ?? {}),
      batterySpecs: OfferBatterySpecs.fromJson(json['battery'] ?? json['battery_specs'] ?? {}),
      inverterSpecs: OfferInverterSpecs.fromJson(json['inverter'] ?? json['inverter_specs'] ?? {}),
      involves: (json['involves'] as List?)?.map((e) => e.toString()).toList() ?? [],
      notes: json['notes'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      expiresAt: json['expires_at'] != null ? DateTime.parse(json['expires_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'company_id': companyId,
      'pv_specs': pvSpecs.toJson(),
      'battery_specs': batterySpecs.toJson(),
      'inverter_specs': inverterSpecs.toJson(),
      'involves': involves,
      'notes': notes,
      'price': price,
      'status': status,
      'expires_at': expiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class OfferPvSpecs {
  final int count;
  final int capacity; // in Watt
  final String? mark;

  OfferPvSpecs({this.count = 0, this.capacity = 0, this.mark});

  factory OfferPvSpecs.fromJson(Map<String, dynamic> json) {
    return OfferPvSpecs(count: json['count'] ?? 0, capacity: json['capacity'] ?? 0, mark: json['mark']);
  }

  Map<String, dynamic> toJson() => {'count': count, 'capacity': capacity, 'mark': mark};
}

class OfferBatterySpecs {
  final int count;
  final double capacity; // kW or Ah
  final String? mark;

  OfferBatterySpecs({this.count = 0, this.capacity = 0.0, this.mark});

  factory OfferBatterySpecs.fromJson(Map<String, dynamic> json) {
    return OfferBatterySpecs(count: json['count'] ?? 0, capacity: (json['capacity'] as num?)?.toDouble() ?? 0.0, mark: json['mark']);
  }

  Map<String, dynamic> toJson() => {'count': count, 'capacity': capacity, 'mark': mark};
}

class OfferInverterSpecs {
  final int count;
  final double capacity; // kW
  final String? mark;
  final String? phase;

  OfferInverterSpecs({this.count = 0, this.capacity = 0.0, this.mark, this.phase});

  factory OfferInverterSpecs.fromJson(Map<String, dynamic> json) {
    return OfferInverterSpecs(count: json['count'] ?? 0, capacity: (json['capacity'] as num?)?.toDouble() ?? 0.0, mark: json['mark'], phase: json['phase']);
  }

  Map<String, dynamic> toJson() => {'count': count, 'capacity': capacity, 'mark': mark, 'phase': phase};
}
