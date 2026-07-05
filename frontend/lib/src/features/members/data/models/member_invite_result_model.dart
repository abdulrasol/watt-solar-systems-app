import 'package:solar_hub/src/features/members/domain/entities/member_invite_result.dart';

class MemberInviteResultModel extends MemberInviteResult {
  const MemberInviteResultModel({
    required super.requiresRegistration,
    required super.message,
    required super.messageUser,
  });

  factory MemberInviteResultModel.fromJson(Map<String, dynamic> json) {
    final body = json['body'] is Map<String, dynamic>
        ? json['body'] as Map<String, dynamic>
        : <String, dynamic>{};

    return MemberInviteResultModel(
      requiresRegistration: body['requires_registration'] == true,
      message: json['message']?.toString() ?? '',
      messageUser: json['message_user']?.toString() ?? '',
    );
  }
}
