import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/summery.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/usecases/get_company_usecase.dart';
import 'package:solar_hub/src/utils/helper_methods.dart';

class CompanySummeryState {
  final bool isLoading;
  final CompanySummery? summery;
  final bool isError;
  final bool isFromCache;
  CompanySummeryState({
    required this.isLoading,
    this.summery,
    this.isError = false,
    this.isFromCache = false,
  });

  CompanySummeryState copyWith({
    bool? isLoading,
    CompanySummery? summery,
    bool? isError,
    bool? isFromCache,
  }) {
    return CompanySummeryState(
      isLoading: isLoading ?? this.isLoading,
      summery: summery ?? this.summery,
      isError: isError ?? this.isError,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  bool isPermisseon(String permission) {
    return summery?.permissionValue(permission) == 'write';
  }
}

final companySummeryProvider =
    NotifierProvider<CompanySummeryNotifier, CompanySummeryState>(
      CompanySummeryNotifier.new,
    );

class CompanySummeryNotifier extends Notifier<CompanySummeryState> {
  @override
  CompanySummeryState build() {
    return CompanySummeryState(isLoading: false);
  }

  Future<void> getSummery() async {
    if (!ref.read(authProvider).isSigned ||
        !ref.read(authProvider).isCompanyMember ||
        ref.read(authProvider).user!.company == null) {
      return;
    }
    state = state.copyWith(isLoading: true, isError: false);
    final result = await getIt<GetCompanySummeryUseCase>().call(
      ref.read(authProvider).user!.company!.id,
    );

    result.fold(
      (l) {
        dPrint(l);

        return l;
      },
      (r) {
        dPrint(r);
        return r;
      },
    );
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, isError: true);
      },
      (summery) {
        ref.read(authProvider.notifier).updateCompany(summery);
        state = state.copyWith(
          isLoading: false,
          summery: summery,
          isError: false,
        );
      },
    );
  }
}
