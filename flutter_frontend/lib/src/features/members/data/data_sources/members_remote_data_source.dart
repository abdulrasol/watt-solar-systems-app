import 'package:dio/dio.dart';
import 'package:watt/src/core/models/response.dart' as local;
import 'package:watt/src/core/services/dio.dart';
import 'package:watt/src/features/members/data/models/company_member_model.dart';
import 'package:watt/src/features/members/data/models/member_invite_result_model.dart';
import 'package:watt/src/utils/app_urls.dart';
import 'package:watt/src/utils/helper_methods.dart';

abstract class MembersRemoteDataSource {
  Future<List<CompanyMemberModel>> getMembers(int companyId);

  Future<MemberInviteResultModel> inviteMember(
    int companyId,
    Map<String, dynamic> payload,
  );

  Future<void> createMember(int companyId, Map<String, dynamic> payload);

  Future<void> deleteMember(int companyId, int memberId);

  Future<void> updateMember(
    int companyId,
    int memberId,
    Map<String, dynamic> payload,
  );
}

class MembersRemoteDataSourceImpl implements MembersRemoteDataSource {
  final DioService _dioService;

  MembersRemoteDataSourceImpl(this._dioService);

  @override
  Future<List<CompanyMemberModel>> getMembers(int companyId) async {
    try {
      final response =
          await _dioService.get(AppUrls.companyMembers(companyId))
              as local.Response;

      if (response.error || response.status != 200) {
        throw Exception(
          response.messageUser.isEmpty
              ? response.message
              : response.messageUser,
        );
      }

      final members = (response.body as List? ?? const []);
      return members
          .whereType<Map>()
          .map(
            (item) =>
                CompanyMemberModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
    } catch (e, stackTrace) {
      dPrint(
        'getMembers error: $e',
        stackTrace: stackTrace,
        tag: 'MembersRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<MemberInviteResultModel> inviteMember(
    int companyId,
    Map<String, dynamic> payload,
  ) async {
    try {
      local.Response response;
      try {
        response = await _dioService.post(
          AppUrls.inviteMember(companyId),
          data: payload,
        );
      } on DioException catch (e) {
        if (e.response != null && e.response!.statusCode == 404) {
          response = local.Response.fromJson(e.response!.data);
        } else {
          rethrow;
        }
      }

      if (response.status != 200 && response.status != 404) {
        throw Exception(
          response.messageUser.isEmpty
              ? response.message
              : response.messageUser,
        );
      }

      return MemberInviteResultModel.fromJson({
        'status': response.status,
        'message': response.message,
        'body': response.body,
        'message_user': response.messageUser,
      });
    } catch (e, stackTrace) {
      dPrint(
        'inviteMember error: $e',
        stackTrace: stackTrace,
        tag: 'MembersRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<void> createMember(int companyId, Map<String, dynamic> payload) async {
    try {
      final response = await _dioService.post(
        AppUrls.createNewMember(companyId),
        data: payload,
      );

      if (response.error || response.status != 200) {
        throw Exception(
          response.messageUser.isEmpty
              ? response.message
              : response.messageUser,
        );
      }
    } catch (e, stackTrace) {
      dPrint(
        'createMember error: $e',
        stackTrace: stackTrace,
        tag: 'MembersRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteMember(int companyId, int memberId) async {
    try {
      final response = await _dioService.delete(
        AppUrls.deleteMember(companyId, memberId),
      );

      if (response.error || response.status != 200) {
        throw Exception(
          response.messageUser.isEmpty
              ? response.message
              : response.messageUser,
        );
      }
    } catch (e, stackTrace) {
      dPrint(
        'deleteMember error: $e',
        stackTrace: stackTrace,
        tag: 'MembersRemoteDataSource',
      );
      rethrow;
    }
  }

  @override
  Future<void> updateMember(
    int companyId,
    int memberId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dioService.patch(
        AppUrls.deleteMember(companyId, memberId), // Reusing the same URL base
        data: payload,
      );

      if (response.error || (response.status != 200 && response.status != 204)) {
        throw Exception(
          response.messageUser.isEmpty
              ? response.message
              : response.messageUser,
        );
      }
    } catch (e, stackTrace) {
      dPrint(
        'updateMember error: $e',
        stackTrace: stackTrace,
        tag: 'MembersRemoteDataSource',
      );
      rethrow;
    }
  }
}
