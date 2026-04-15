import 'package:solar_hub/src/features/members/domain/entities/company_member.dart';
import 'package:solar_hub/src/features/members/domain/entities/member_invite_result.dart';

abstract class MembersRepository {
  Future<List<CompanyMember>> getMembers(int companyId);

  Future<MemberInviteResult> inviteMember(
    int companyId,
    Map<String, dynamic> payload,
  );

  Future<void> createMember(int companyId, Map<String, dynamic> payload);

  Future<void> deleteMember(int companyId, int memberId);
}
