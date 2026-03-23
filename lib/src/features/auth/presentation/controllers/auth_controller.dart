import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/cashe/cashe_interface.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
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
    cashe.saveUser(response.user);
    cashe.saveToken(response.token!);
    state = state.copyWith(user: response.user, isSigned: true);
  }

  Future<void> logout() async {
    cashe.delete('token');
    cashe.delete('user');
    state = AuthState(user: null, isSigned: false);
  }

  Future<void> updateProfile(User user) async {
    cashe.saveUser(user);
    state = state.copyWith(user: user);
  }

  Future<void> register(AuthResponse response) async {
    cashe.saveUser(response.user);
    cashe.saveToken(response.token!);
    state = state.copyWith(user: response.user, isSigned: true);
  }

  Future<void> fetchProfile(User user) async {
    cashe.saveUser(user);
    state = state.copyWith(user: user);
  }

  Future<void> registerCompany(Company company) async {
    state = state.copyWith(
      user: state.user?.copyWith(company: company, isCompanyMember: true),
    );
    cashe.saveUser(state.user!);
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});
