import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/entities/summary.dart';
import 'package:solar_hub/src/features/company_dashboard/domain/usecases/get_company_usecase.dart';

class CompanySummaryState {
  final bool isLoading;
  final CompanySummary? summary;
  final bool isError;
  final bool isFromCache;
  CompanySummaryState({
    required this.isLoading,
    this.summary,
    this.isError = false,
    this.isFromCache = false,
  });

  CompanySummaryState copyWith({
    bool? isLoading,
    CompanySummary? summary,
    bool? isError,
    bool? isFromCache,
  }) {
    return CompanySummaryState(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      isError: isError ?? this.isError,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  bool isPermission(String permission) {
    return summary?.permissionValue(permission) == 'write';
  }
}

final companySummaryProvider =
    NotifierProvider<CompanySummaryNotifier, CompanySummaryState>(
      CompanySummaryNotifier.new,
    );

class CompanySummaryNotifier extends Notifier<CompanySummaryState> {
  @override
  CompanySummaryState build() {
    return CompanySummaryState(isLoading: false);
  }

  Future<void> getSummary() async {
    if (!ref.read(authProvider).isSigned ||
        !ref.read(authProvider).isCompanyMember ||
        ref.read(authProvider).user!.company == null) {
      return;
    }
    state = state.copyWith(isLoading: true, isError: false);
    final result = await getIt<GetCompanySummaryUseCase>().call(
      ref.read(authProvider).user!.company!.id,
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, isError: true);
      },
      (summary) {
        ref.read(authProvider.notifier).updateCompany(summary);
        state = state.copyWith(
          isLoading: false,
          summary: summary,
          isError: false,
        );
      },
    );
  }
}
