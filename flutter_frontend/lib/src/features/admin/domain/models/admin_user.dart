class AdminUser {
  final int id;
  final String email;
  final String username;
  final String? firstName;
  final String? lastName;
  final bool isSuperuser;
  final String? image;

  const AdminUser({
    required this.id,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    required this.isSuperuser,
    this.image,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as int? ?? 0,
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      firstName: json['first_name']?.toString(),
      lastName: json['last_name']?.toString(),
      isSuperuser: json['is_superuser'] as bool? ?? false,
      image: json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'is_superuser': isSuperuser,
      'image': image,
    };
  }

  AdminUser copyWith({
    int? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    bool? isSuperuser,
    String? image,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      image: image ?? this.image,
    );
  }

  String get fullName => '$firstName $lastName'.trim().isNotEmpty
      ? '$firstName $lastName'.trim()
      : username;
}
