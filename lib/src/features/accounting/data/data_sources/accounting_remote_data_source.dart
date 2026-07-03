import 'package:solar_hub/src/core/models/response.dart';
import 'package:solar_hub/src/core/services/dio.dart';
import 'package:solar_hub/src/features/accounting/domain/entities/accounting_models.dart';
import 'package:solar_hub/src/utils/app_urls.dart';

abstract class AccountingRemoteDataSource {
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

class AccountingRemoteDataSourceImpl implements AccountingRemoteDataSource {
  final DioService _dioService;

  AccountingRemoteDataSourceImpl(this._dioService);

  @override
  Future<AccountRecord> createAccount(
    int companyId,
    AccountWriteRequest request,
  ) async {
    final response = await _dioService.post(
      AppUrls.accountingAccounts(companyId),
      data: request.toJson(),
    );
    return AccountRecord.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }

  @override
  Future<PaymentRecord> createPayment(
    int companyId,
    PaymentCreateRequest request,
  ) async {
    final response = await _dioService.post(
      AppUrls.accountingPayments(companyId),
      data: request.toJson(),
    );
    return PaymentRecord.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }

  @override
  Future<void> deleteAccount(int companyId, int accountId) =>
      _dioService.delete(AppUrls.accountingAccount(companyId, accountId));

  @override
  Future<BillRecord> getBill(int companyId, int billId) async {
    final response =
        await _dioService.get(AppUrls.accountingBill(companyId, billId))
            as Response;
    return BillRecord.fromJson(Map<String, dynamic>.from(response.body as Map));
  }

  @override
  Future<InvoiceRecord> getInvoice(int companyId, int invoiceId) async {
    final response =
        await _dioService.get(AppUrls.accountingInvoice(companyId, invoiceId))
            as Response;
    return InvoiceRecord.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }

  @override
  Future<LedgerSummary> getLedger(int companyId) async {
    final response =
        await _dioService.get(AppUrls.accountingLedger(companyId)) as Response;
    return LedgerSummary.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }

  @override
  Future<AccountingOverview> getOverview(int companyId) async {
    final response =
        await _dioService.get(AppUrls.accountingOverview(companyId))
            as Response;
    return AccountingOverview.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }

  @override
  Future<PaginatedItemsResponse<AccountRecord>> listAccounts(
    int companyId, {
    AccountQuery query = const AccountQuery(),
  }) async {
    final response = await _dioService.getRawMap(
      AppUrls.accountingAccounts(companyId),
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedItemsResponse<AccountRecord>.fromJson(
      response,
      AccountRecord.fromJson,
    );
  }

  @override
  Future<PaginatedItemsResponse<BillRecord>> listBills(
    int companyId, {
    BillQuery query = const BillQuery(),
  }) async {
    final response = await _dioService.getRawMap(
      AppUrls.accountingBills(companyId),
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedItemsResponse<BillRecord>.fromJson(
      response,
      BillRecord.fromJson,
    );
  }

  @override
  Future<PaginatedItemsResponse<InvoiceRecord>> listInvoices(
    int companyId, {
    InvoiceQuery query = const InvoiceQuery(),
  }) async {
    final response = await _dioService.getRawMap(
      AppUrls.accountingInvoices(companyId),
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedItemsResponse<InvoiceRecord>.fromJson(
      response,
      InvoiceRecord.fromJson,
    );
  }

  @override
  Future<PaginatedItemsResponse<JournalEntryRecord>> listJournalEntries(
    int companyId, {
    JournalQuery query = const JournalQuery(),
  }) async {
    final response = await _dioService.getRawMap(
      AppUrls.accountingJournal(companyId),
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedItemsResponse<JournalEntryRecord>.fromJson(
      response,
      JournalEntryRecord.fromJson,
    );
  }

  @override
  Future<PaginatedItemsResponse<PayableRecord>> listPayables(
    int companyId, {
    ListQuery query = const ListQuery(ordering: '-balance_due'),
  }) async {
    final response = await _dioService.getRawMap(
      AppUrls.accountingPayables(companyId),
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedItemsResponse<PayableRecord>.fromJson(
      response,
      PayableRecord.fromJson,
    );
  }

  @override
  Future<PaginatedItemsResponse<PaymentRecord>> listPayments(
    int companyId, {
    PaymentQuery query = const PaymentQuery(),
  }) async {
    final response = await _dioService.getRawMap(
      AppUrls.accountingPayments(companyId),
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedItemsResponse<PaymentRecord>.fromJson(
      response,
      PaymentRecord.fromJson,
    );
  }

  @override
  Future<PaginatedItemsResponse<ReceivableRecord>> listReceivables(
    int companyId, {
    ListQuery query = const ListQuery(ordering: '-balance_due'),
  }) async {
    final response = await _dioService.getRawMap(
      AppUrls.accountingReceivables(companyId),
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedItemsResponse<ReceivableRecord>.fromJson(
      response,
      ReceivableRecord.fromJson,
    );
  }

  @override
  Future<PaginatedItemsResponse<TransactionRecord>> listTransactions(
    int companyId, {
    ListQuery query = const ListQuery(),
  }) async {
    final response = await _dioService.getRawMap(
      AppUrls.accountingTransactions(companyId),
      queryParameters: query.toQueryParameters(),
    );
    return PaginatedItemsResponse<TransactionRecord>.fromJson(
      response,
      TransactionRecord.fromJson,
    );
  }

  @override
  Future<AccountRecord> updateAccount(
    int companyId,
    int accountId,
    AccountWriteRequest request,
  ) async {
    final response = await _dioService.put(
      AppUrls.accountingAccount(companyId, accountId),
      data: request.toJson(),
    );
    return AccountRecord.fromJson(
      Map<String, dynamic>.from(response.body as Map),
    );
  }
}
