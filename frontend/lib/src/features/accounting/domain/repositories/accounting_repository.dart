import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/features/accounting/domain/entities/accounting_models.dart';

abstract class AccountingRepository {
  Future<AccountingOverview> getOverview(int companyId);
  Future<LedgerSummary> getLedger(int companyId);
  Future<PaginatedItemsResponse<AccountRecord>> listAccounts(
    int companyId, {
    AccountQuery query = const AccountQuery(),
  });
  Future<AccountRecord> createAccount(
    int companyId,
    AccountWriteRequest request,
  );
  Future<AccountRecord> updateAccount(
    int companyId,
    int accountId,
    AccountWriteRequest request,
  );
  Future<void> deleteAccount(int companyId, int accountId);
  Future<PaginatedItemsResponse<InvoiceRecord>> listInvoices(
    int companyId, {
    InvoiceQuery query = const InvoiceQuery(),
  });
  Future<InvoiceRecord> getInvoice(int companyId, int invoiceId);
  Future<PaginatedItemsResponse<BillRecord>> listBills(
    int companyId, {
    BillQuery query = const BillQuery(),
  });
  Future<BillRecord> getBill(int companyId, int billId);
  Future<PaginatedItemsResponse<PaymentRecord>> listPayments(
    int companyId, {
    PaymentQuery query = const PaymentQuery(),
  });
  Future<PaymentRecord> createPayment(
    int companyId,
    PaymentCreateRequest request,
  );
  Future<PaginatedItemsResponse<JournalEntryRecord>> listJournalEntries(
    int companyId, {
    JournalQuery query = const JournalQuery(),
  });
  Future<PaginatedItemsResponse<ReceivableRecord>> listReceivables(
    int companyId, {
    ListQuery query = const ListQuery(ordering: '-balance_due'),
  });
  Future<PaginatedItemsResponse<PayableRecord>> listPayables(
    int companyId, {
    ListQuery query = const ListQuery(ordering: '-balance_due'),
  });
  Future<PaginatedItemsResponse<TransactionRecord>> listTransactions(
    int companyId, {
    ListQuery query = const ListQuery(),
  });
}
