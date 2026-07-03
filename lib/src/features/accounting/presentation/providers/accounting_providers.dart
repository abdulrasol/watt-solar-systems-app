import 'package:flutter_riverpod/flutter_riverpod.dart' show FutureProvider;
import 'package:flutter_riverpod/legacy.dart';
import 'package:solar_hub/src/core/di/get_it.dart';
import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/features/accounting/domain/entities/accounting_models.dart';
import 'package:solar_hub/src/features/accounting/domain/repositories/accounting_repository.dart';

class AccountingDashboardState {
  final bool isLoading;
  final String? error;
  final AccountingOverview? overview;
  final LedgerSummary? ledger;

  const AccountingDashboardState({
    this.isLoading = false,
    this.error,
    this.overview,
    this.ledger,
  });

  AccountingDashboardState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    AccountingOverview? overview,
    LedgerSummary? ledger,
  }) {
    return AccountingDashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      overview: overview ?? this.overview,
      ledger: ledger ?? this.ledger,
    );
  }
}

class AccountingDashboardController
    extends StateNotifier<AccountingDashboardState> {
  final int companyId;
  final AccountingRepository _repository;

  AccountingDashboardController(this.companyId, this._repository)
    : super(const AccountingDashboardState(isLoading: true)) {
    fetch();
  }

  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final overview = await _repository.getOverview(companyId);
      final ledger = await _repository.getLedger(companyId);
      state = state.copyWith(
        isLoading: false,
        overview: overview,
        ledger: ledger,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final accountingDashboardProvider =
    StateNotifierProvider.family<
      AccountingDashboardController,
      AccountingDashboardState,
      int
    >(
      (ref, companyId) => AccountingDashboardController(
        companyId,
        getIt<AccountingRepository>(),
      ),
    );

final accountsProvider =
    FutureProvider.family<PaginatedItemsResponse<AccountRecord>, int>(
      (ref, companyId) => getIt<AccountingRepository>().listAccounts(companyId),
    );
final invoicesProvider =
    FutureProvider.family<PaginatedItemsResponse<InvoiceRecord>, int>(
      (ref, companyId) => getIt<AccountingRepository>().listInvoices(companyId),
    );
final billsProvider =
    FutureProvider.family<PaginatedItemsResponse<BillRecord>, int>(
      (ref, companyId) => getIt<AccountingRepository>().listBills(companyId),
    );
final paymentsProvider =
    FutureProvider.family<PaginatedItemsResponse<PaymentRecord>, int>(
      (ref, companyId) => getIt<AccountingRepository>().listPayments(companyId),
    );
final journalEntriesProvider =
    FutureProvider.family<PaginatedItemsResponse<JournalEntryRecord>, int>(
      (ref, companyId) =>
          getIt<AccountingRepository>().listJournalEntries(companyId),
    );
final receivablesProvider =
    FutureProvider.family<PaginatedItemsResponse<ReceivableRecord>, int>(
      (ref, companyId) =>
          getIt<AccountingRepository>().listReceivables(companyId),
    );
final payablesProvider =
    FutureProvider.family<PaginatedItemsResponse<PayableRecord>, int>(
      (ref, companyId) => getIt<AccountingRepository>().listPayables(companyId),
    );
final transactionsProvider =
    FutureProvider.family<PaginatedItemsResponse<TransactionRecord>, int>(
      (ref, companyId) =>
          getIt<AccountingRepository>().listTransactions(companyId),
    );
final invoiceDetailProvider =
    FutureProvider.family<InvoiceRecord, ({int companyId, int invoiceId})>(
      (ref, args) => getIt<AccountingRepository>().getInvoice(
        args.companyId,
        args.invoiceId,
      ),
    );
final billDetailProvider =
    FutureProvider.family<BillRecord, ({int companyId, int billId})>(
      (ref, args) =>
          getIt<AccountingRepository>().getBill(args.companyId, args.billId),
    );
