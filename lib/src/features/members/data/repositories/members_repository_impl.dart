import 'package:solar_hub/src/features/members/data/data_sources/members_remote_data_source.dart';
import 'package:solar_hub/src/features/members/domain/entities/company_member.dart';
import 'package:solar_hub/src/features/members/domain/entities/member_invite_result.dart';
import 'package:solar_hub/src/features/members/domain/repositories/members_repository.dart';

class MembersRepositoryImpl implements MembersRepository {
  final MembersRemoteDataSource remoteDataSource;

  MembersRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CompanyMember>> getMembers(int companyId) {
    return remoteDataSource.getMembers(companyId);
  }

  @override
  Future<MemberInviteResult> inviteMember(
    int companyId,
    Map<String, dynamic> payload,
  ) {
    return remoteDataSource.inviteMember(companyId, payload);
  }

  @override
  Future<void> createMember(int companyId, Map<String, dynamic> payload) {
    return remoteDataSource.createMember(companyId, payload);
  }

  @override
  Future<void> deleteMember(int companyId, int memberId) {
    return remoteDataSource.deleteMember(companyId, memberId);
  }
}
