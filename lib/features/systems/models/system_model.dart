class SystemComponent {
  final int count;
  final double capacity;
  final String? mark; // Brand/Model
  final String? phase; // For inverter

  SystemComponent({this.count = 0, this.capacity = 0.0, this.mark, this.phase});

  factory SystemComponent.fromJson(Map<String, dynamic> json) {
    return SystemComponent(
      count: json['count'] is int ? json['count'] : int.tryParse(json['count'].toString()) ?? 0,
      capacity: json['capacity'] is num ? (json['capacity'] as num).toDouble() : double.tryParse(json['capacity'].toString()) ?? 0.0,
      mark: json['mark'],
      phase: json['phase'],
    );
  }

  Map<String, dynamic> toJson() => {'count': count, 'capacity': capacity, 'mark': mark, 'phase': phase};
}

class SystemModel {
  String? id;
  String? userId; // "user_id" column (UUID)
  String? userPhone; // "user" column (Legacy/Fallback)
  String userStatus;
  String? installedBy; // company_id
  String companyStatus;

  // Relation Fields (Fetched via lookup/joins)
  String? companyName;
  String? companyLogo;
  String? userName;
  String? userAvatar; // Optional but good for UI

  SystemComponent pv;
  SystemComponent battery;
  SystemComponent inverter;

  String? notes;
  double lat;
  double lan; // Keeping 'lan' as in DB schema (usually lon)
  String? address;
  String? city;
  String? country;

  DateTime? installedAt;
  String? orderId;
  DateTime? createdAt;

  SystemModel({
    this.id,
    this.userId,
    this.userPhone,
    this.userStatus = 'pending',
    this.installedBy,
    this.companyStatus = 'pending',
    required this.pv,
    required this.battery,
    required this.inverter,
    this.notes,
    this.lat = 0.0,
    this.lan = 0.0,
    this.address,
    this.city,
    this.country,
    this.installedAt,
    this.orderId,
    this.createdAt,
    this.companyName,
    this.companyLogo,
    this.userName,
    this.userAvatar,
  });

  SystemModel copyWith({
    String? id,
    String? userId,
    String? userPhone,
    String? userStatus,
    String? installedBy,
    String? companyStatus,
    SystemComponent? pv,
    SystemComponent? battery,
    SystemComponent? inverter,
    String? notes,
    double? lat,
    double? lan,
    String? address,
    String? city,
    String? country,
    DateTime? installedAt,
    String? orderId,
    DateTime? createdAt,
    String? companyName,
    String? companyLogo,
    String? userName,
    String? userAvatar,
  }) {
    return SystemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userPhone: userPhone ?? this.userPhone,
      userStatus: userStatus ?? this.userStatus,
      installedBy: installedBy ?? this.installedBy,
      companyStatus: companyStatus ?? this.companyStatus,
      pv: pv ?? this.pv,
      battery: battery ?? this.battery,
      inverter: inverter ?? this.inverter,
      notes: notes ?? this.notes,
      lat: lat ?? this.lat,
      lan: lan ?? this.lan,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      installedAt: installedAt ?? this.installedAt,
      orderId: orderId ?? this.orderId,
      createdAt: createdAt ?? this.createdAt,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
    );
  }

  factory SystemModel.fromJson(Map<String, dynamic> json) {
    return SystemModel(
      id: json['id'],
      userId: json['user_id'],
      userPhone: json['user'],
      userStatus: json['user_status'] ?? 'pending',
      installedBy: json['installed_by'],
      companyStatus: json['company_status'] ?? 'pending',
      pv: SystemComponent.fromJson(json['pv'] ?? {}),
      battery: SystemComponent.fromJson(json['battery'] ?? {}),
      inverter: SystemComponent.fromJson(json['inverter'] ?? {}),
      notes: json['notes'],
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lan: (json['lan'] as num?)?.toDouble() ?? 0.0,
      address: json['address'],
      city: json['city'],
      country: json['country'],
      installedAt: json['installed_at'] != null ? DateTime.parse(json['installed_at']) : null,
      orderId: json['order_id'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,

      // Parse joined data if available
      companyName: json['companies'] != null ? json['companies']['name'] : null,
      companyLogo: json['companies'] != null ? json['companies']['logo_url'] : null,
      userName: json['profiles'] != null ? json['profiles']['full_name'] : null,
      userAvatar: json['profiles'] != null ? json['profiles']['avatar_url'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'user_id': userId,
      'user': userPhone,
      'user_status': userStatus,
      'installed_by': installedBy,
      'company_status': companyStatus,
      'pv': pv.toJson(),
      'battery': battery.toJson(),
      'inverter': inverter.toJson(),
      'notes': notes,
      'lat': lat,
      'lan': lan,
      'address': address,
      'city': city,
      'country': country,
      'installed_at': installedAt?.toIso8601String(),
      'order_id': orderId,
    };
    if (id != null) data['id'] = id;
    return data;
  }
}
