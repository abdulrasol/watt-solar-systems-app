import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/features/auth/domain/entities/user.dart';

class AuthResponse extends BaseResponse {
  final String? token;
  final User user;
  final bool isUpdate;

  AuthResponse({this.token, required this.user, this.isUpdate = false}) {
    body = {'token': token, 'user': user};
    status = 200;
    message = '';
    error = false;
    messageUser = '';
  }

  factory AuthResponse.fromBase(BaseResponse baseResponse) {
    return AuthResponse(token: baseResponse.body['token'], user: User.fromJson(baseResponse.body['user']));
  }
}
