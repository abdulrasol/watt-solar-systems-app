import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/services/push_notification_service.dart';
import 'package:solar_hub/src/features/auth/domain/entities/auth_response.dart';
import 'package:solar_hub/src/features/auth/domain/entities/company.dart';
import 'package:solar_hub/src/features/auth/domain/entities/user.dart';

class AuthState {
  final User? user;
  final bool isSigned;

  AuthState({this.user, this.isSigned = false});

  AuthState copyWith({User? user, bool? isSigned}) {
    return AuthState(
      user: user ?? this.user,
      isSigned: isSigned ?? this.isSigned,
    );
  }

  bool get isCompanyMember => user?.isCompanyMember == true;
  bool get isSuperUser => user?.isSuperUser == true;
  Company? get company => user?.company;
}

class AuthController extends Notifier<AuthState> {
  late CasheInterface cashe;

  @override
  AuthState build() {
    cashe = getIt<CasheInterface>();

    final initialUser = cashe.user();
    final initialIsSigned = cashe.get('token') != null && initialUser != null;

    cashe.box.listenKey('user', (value) {
      if (value != null) {
        state = state.copyWith(
          user: User.fromJson(Map<String, dynamic>.from(value)),
        );
      } else {
        state = AuthState(user: null, isSigned: state.isSigned);
      }
    });

    return AuthState(user: initialUser, isSigned: initialIsSigned);
  }

  Future<void> login(AuthResponse response) async {
    await cashe.saveUser(response.user);
    await cashe.saveToken(response.token!);
    state = state.copyWith(user: response.user, isSigned: true);
    await getIt<PushNotificationService>().onAuthenticated();
  }

  Future<void> logout() async {
    await cashe.delete('token');
    await cashe.delete('user');
    state = AuthState(user: null, isSigned: false);
    await getIt<PushNotificationService>().onLoggedOut();
  }

  Future<void> updateProfile(User user) async {
    await cashe.saveUser(user);
    state = state.copyWith(user: user);
  }

  Future<void> register(AuthResponse response) async {
    await cashe.saveUser(response.user);
    await cashe.saveToken(response.token!);
    state = state.copyWith(user: response.user, isSigned: true);
    await getIt<PushNotificationService>().onAuthenticated();
  }

  Future<void> fetchProfile(User user) async {
    await cashe.saveUser(user);
    state = state.copyWith(user: user);
    if (state.isSigned) {
      await getIt<PushNotificationService>().onAuthenticated();
    }
  }

  Future<void> registerCompany(Company company) async {
    state = state.copyWith(
      user: state.user?.copyWith(company: company, isCompanyMember: true),
    );
    await cashe.saveUser(state.user!);
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});
