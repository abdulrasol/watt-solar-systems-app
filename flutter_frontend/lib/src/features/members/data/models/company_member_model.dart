import 'package:solar_hub/src/features/members/domain/entities/company_member.dart';
import 'package:solar_hub/src/features/members/domain/entities/member_role.dart';

class CompanyMemberModel extends CompanyMember {
  const CompanyMemberModel({
    required super.id,
    required super.username,
    required super.email,
    required super.role,
    super.joinedAt,
  });

  factory CompanyMemberModel.fromJson(Map<String, dynamic> json) {
    return CompanyMemberModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: MemberRole.fromValue(json['role']?.toString()),
      joinedAt: json['joined_at'] == null
          ? null
          : DateTime.tryParse(json['joined_at'].toString()),
    );
  }
}
