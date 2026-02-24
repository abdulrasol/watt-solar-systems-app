class ProfileModel {
  final String id;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProfileModel({required this.id, this.fullName, this.phoneNumber, this.avatarUrl, this.isVerified = false, this.createdAt, this.updatedAt});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'avatar_url': avatarUrl,
      'is_verified': isVerified,
      // created_at and updated_at are usually handled by DB on write
    };
  }
}
