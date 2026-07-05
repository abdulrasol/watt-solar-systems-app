import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';

bool canViewStorefrontB2bDetails(AuthState authState) {
  final role = authState.company?.memberRole?.toLowerCase();
  return authState.isCompanyMember && (role == 'admin' || role == 'manager');
}
