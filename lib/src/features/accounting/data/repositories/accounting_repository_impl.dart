import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/features/accounting/data/datasources/accounting_remote_data_source.dart';
import 'package:solar_hub/src/features/accounting/domain/entities/accounting_models.dart';
import 'package:solar_hub/src/features/accounting/domain/repositories/accounting_repository.dart';

class AccountingRepositoryImpl implements AccountingRepository {
  final AccountingRemoteDataSource _remoteDataSource;

  AccountingRepositoryImpl(this._remoteDataSource);

  @override
  Future<AccountRecord> createAccount(
    int companyId,
    AccountWriteRequest request,
  ) => _remoteDataSource.createAccount(companyId, request);

  @override
  Future<PaymentRecord> createPayment(
    int companyId,
    PaymentCreateRequest request,
  ) => _remoteDataSource.createPayment(companyId, request);

  @override
  Future<void> deleteAccount(int companyId, int accountId) =>
      _remoteDataSource.deleteAccount(companyId, accountId);

  @override
  Future<BillRecord> getBill(int companyId, int billId) =>
      _remoteDataSource.getBill(companyId, billId);

  @override
  Future<InvoiceRecord> getInvoice(int companyId, int invoiceId) =>
      _remoteDataSource.getInvoice(companyId, invoiceId);

  @override
  Future<LedgerSummary> getLedger(int companyId) =>
      _remoteDataSource.getLedger(companyId);

  @override
  Future<AccountingOverview> getOverview(int companyId) =>
      _remoteDataSource.getOverview(companyId);

  @override
  Future<PaginatedItemsResponse<AccountRecord>> listAccounts(
    int companyId, {
    AccountQuery query = const AccountQuery(),
  }) => _remoteDataSource.listAccounts(companyId, query: query);

  @override
  Future<PaginatedItemsResponse<BillRecord>> listBills(
    int companyId, {
    BillQuery query = const BillQuery(),
  }) => _remoteDataSource.listBills(companyId, query: query);

  @override
  Future<PaginatedItemsResponse<InvoiceRecord>> listInvoices(
    int companyId, {
    InvoiceQuery query = const InvoiceQuery(),
  }) => _remoteDataSource.listInvoices(companyId, query: query);

  @override
  Future<PaginatedItemsResponse<JournalEntryRecord>> listJournalEntries(
    int companyId, {
    JournalQuery query = const JournalQuery(),
  }) => _remoteDataSource.listJournalEntries(companyId, query: query);

  @override
  Future<PaginatedItemsResponse<PayableRecord>> listPayables(
    int companyId, {
    ListQuery query = const ListQuery(ordering: '-balance_due'),
  }) => _remoteDataSource.listPayables(companyId, query: query);

  @override
  Future<PaginatedItemsResponse<PaymentRecord>> listPayments(
    int companyId, {
    PaymentQuery query = const PaymentQuery(),
  }) => _remoteDataSource.listPayments(companyId, query: query);

  @override
  Future<PaginatedItemsResponse<ReceivableRecord>> listReceivables(
    int companyId, {
    ListQuery query = const ListQuery(ordering: '-balance_due'),
  }) => _remoteDataSource.listReceivables(companyId, query: query);

  @override
  Future<PaginatedItemsResponse<TransactionRecord>> listTransactions(
    int companyId, {
    ListQuery query = const ListQuery(),
  }) => _remoteDataSource.listTransactions(companyId, query: query);

  @override
  Future<AccountRecord> updateAccount(
    int companyId,
    int accountId,
    AccountWriteRequest request,
  ) => _remoteDataSource.updateAccount(companyId, accountId, request);
}
