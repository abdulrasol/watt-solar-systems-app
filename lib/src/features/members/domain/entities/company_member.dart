import 'package:solar_hub/src/features/members/domain/entities/member_role.dart';

class CompanyMember {
  final int id;
  final String username;
  final String email;
  final MemberRole role;
  final DateTime? joinedAt;

  const CompanyMember({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.joinedAt,
  });
}
