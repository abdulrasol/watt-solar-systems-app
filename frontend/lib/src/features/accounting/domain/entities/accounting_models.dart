class AccountingOverview {
  final int invoicesTotal;
  final int billsTotal;
  final int paymentsTotal;
  final double receivablesTotal;
  final double payablesTotal;
  final double paymentsIncomingTotal;
  final double paymentsOutgoingTotal;

  const AccountingOverview({
    required this.invoicesTotal,
    required this.billsTotal,
    required this.paymentsTotal,
    required this.receivablesTotal,
    required this.payablesTotal,
    required this.paymentsIncomingTotal,
    required this.paymentsOutgoingTotal,
  });

  factory AccountingOverview.fromJson(Map<String, dynamic> json) {
    return AccountingOverview(
      invoicesTotal: json['invoices_total'] ?? 0,
      billsTotal: json['bills_total'] ?? 0,
      paymentsTotal: json['payments_total'] ?? 0,
      receivablesTotal: (json['receivables_total'] as num?)?.toDouble() ?? 0,
      payablesTotal: (json['payables_total'] as num?)?.toDouble() ?? 0,
      paymentsIncomingTotal:
          (json['payments_incoming_total'] as num?)?.toDouble() ?? 0,
      paymentsOutgoingTotal:
          (json['payments_outgoing_total'] as num?)?.toDouble() ?? 0,
    );
  }
}

class LedgerSummary {
  final double asset;
  final double liability;
  final double equity;
  final double revenue;
  final double expense;
  final double netIncome;

  const LedgerSummary({
    required this.asset,
    required this.liability,
    required this.equity,
    required this.revenue,
    required this.expense,
    required this.netIncome,
  });

  factory LedgerSummary.fromJson(Map<String, dynamic> json) {
    return LedgerSummary(
      asset: (json['asset'] as num?)?.toDouble() ?? 0,
      liability: (json['liability'] as num?)?.toDouble() ?? 0,
      equity: (json['equity'] as num?)?.toDouble() ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      expense: (json['expense'] as num?)?.toDouble() ?? 0,
      netIncome: (json['net_income'] as num?)?.toDouble() ?? 0,
    );
  }
}

class AccountingCounterparty {
  final int id;
  final String name;

  const AccountingCounterparty({required this.id, required this.name});

  factory AccountingCounterparty.fromJson(Map<String, dynamic> json) {
    return AccountingCounterparty(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class AccountRecord {
  final int id;
  final String name;
  final String code;
  final String accountType;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AccountRecord({
    required this.id,
    required this.name,
    required this.code,
    required this.accountType,
    this.description,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory AccountRecord.fromJson(Map<String, dynamic> json) {
    return AccountRecord(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      accountType: json['account_type']?.toString() ?? '',
      description: json['description']?.toString(),
      isActive: json['is_active'] != false,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}

class InvoiceRecord {
  final int id;
  final String invoiceNumber;
  final int companyId;
  final AccountingCounterparty customer;
  final int? orderId;
  final String issueDate;
  final String? dueDate;
  final double totalAmount;
  final double paidAmount;
  final double balanceDue;
  final String status;
  final int? journalEntryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InvoiceRecord({
    required this.id,
    required this.invoiceNumber,
    required this.companyId,
    required this.customer,
    this.orderId,
    required this.issueDate,
    this.dueDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.balanceDue,
    required this.status,
    this.journalEntryId,
    this.createdAt,
    this.updatedAt,
  });

  factory InvoiceRecord.fromJson(Map<String, dynamic> json) {
    return InvoiceRecord(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoice_number']?.toString() ?? '',
      companyId: json['company_id'] ?? 0,
      customer: AccountingCounterparty.fromJson(
        Map<String, dynamic>.from(
          json['customer'] ?? const <String, dynamic>{},
        ),
      ),
      orderId: json['order_id'],
      issueDate: json['issue_date']?.toString() ?? '',
      dueDate: json['due_date']?.toString(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      balanceDue: (json['balance_due'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? '',
      journalEntryId: json['journal_entry_id'],
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}

class BillRecord {
  final int id;
  final String billNumber;
  final int companyId;
  final AccountingCounterparty supplier;
  final int? orderId;
  final String issueDate;
  final String? dueDate;
  final double totalAmount;
  final double paidAmount;
  final double balanceDue;
  final String status;
  final int? journalEntryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BillRecord({
    required this.id,
    required this.billNumber,
    required this.companyId,
    required this.supplier,
    this.orderId,
    required this.issueDate,
    this.dueDate,
    required this.totalAmount,
    required this.paidAmount,
    required this.balanceDue,
    required this.status,
    this.journalEntryId,
    this.createdAt,
    this.updatedAt,
  });

  factory BillRecord.fromJson(Map<String, dynamic> json) {
    return BillRecord(
      id: json['id'] ?? 0,
      billNumber: json['bill_number']?.toString() ?? '',
      companyId: json['company_id'] ?? 0,
      supplier: AccountingCounterparty.fromJson(
        Map<String, dynamic>.from(
          json['supplier'] ?? const <String, dynamic>{},
        ),
      ),
      orderId: json['order_id'],
      issueDate: json['issue_date']?.toString() ?? '',
      dueDate: json['due_date']?.toString(),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      balanceDue: (json['balance_due'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? '',
      journalEntryId: json['journal_entry_id'],
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}

class PaymentRecord {
  final int id;
  final int companyId;
  final int? invoiceId;
  final int? billId;
  final String paymentType;
  final double amount;
  final String paymentDate;
  final String paymentMethod;
  final String? reference;
  final int? journalEntryId;
  final DateTime? createdAt;

  const PaymentRecord({
    required this.id,
    required this.companyId,
    this.invoiceId,
    this.billId,
    required this.paymentType,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.reference,
    this.journalEntryId,
    this.createdAt,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id'] ?? 0,
      companyId: json['company_id'] ?? 0,
      invoiceId: json['invoice_id'],
      billId: json['bill_id'],
      paymentType: json['payment_type']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      paymentDate: json['payment_date']?.toString() ?? '',
      paymentMethod: json['payment_method']?.toString() ?? '',
      reference: json['reference']?.toString(),
      journalEntryId: json['journal_entry_id'],
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

class JournalLineRecord {
  final int id;
  final int accountId;
  final String accountName;
  final String? description;
  final double debit;
  final double credit;

  const JournalLineRecord({
    required this.id,
    required this.accountId,
    required this.accountName,
    this.description,
    required this.debit,
    required this.credit,
  });

  factory JournalLineRecord.fromJson(Map<String, dynamic> json) {
    return JournalLineRecord(
      id: json['id'] ?? 0,
      accountId: json['account_id'] ?? 0,
      accountName: json['account_name']?.toString() ?? '',
      description: json['description']?.toString(),
      debit: (json['debit'] as num?)?.toDouble() ?? 0,
      credit: (json['credit'] as num?)?.toDouble() ?? 0,
    );
  }
}

class JournalEntryRecord {
  final int id;
  final String date;
  final String description;
  final String? reference;
  final int companyId;
  final bool isBalanced;
  final List<JournalLineRecord> lines;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const JournalEntryRecord({
    required this.id,
    required this.date,
    required this.description,
    this.reference,
    required this.companyId,
    required this.isBalanced,
    this.lines = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory JournalEntryRecord.fromJson(Map<String, dynamic> json) {
    return JournalEntryRecord(
      id: json['id'] ?? 0,
      date: json['date']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      reference: json['reference']?.toString(),
      companyId: json['company_id'] ?? 0,
      isBalanced: json['is_balanced'] == true,
      lines: (json['lines'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (line) =>
                JournalLineRecord.fromJson(Map<String, dynamic>.from(line)),
          )
          .toList(),
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}

class ReceivableRecord {
  final int customerId;
  final String customerName;
  final double totalAmount;
  final double paidAmount;
  final double balanceDue;
  final int invoicesCount;

  const ReceivableRecord({
    required this.customerId,
    required this.customerName,
    required this.totalAmount,
    required this.paidAmount,
    required this.balanceDue,
    required this.invoicesCount,
  });

  factory ReceivableRecord.fromJson(Map<String, dynamic> json) {
    return ReceivableRecord(
      customerId: json['customer_id'] ?? 0,
      customerName: json['customer_name']?.toString() ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      balanceDue: (json['balance_due'] as num?)?.toDouble() ?? 0,
      invoicesCount: json['invoices_count'] ?? 0,
    );
  }
}

class PayableRecord {
  final int supplierId;
  final String supplierName;
  final double totalAmount;
  final double paidAmount;
  final double balanceDue;
  final int billsCount;

  const PayableRecord({
    required this.supplierId,
    required this.supplierName,
    required this.totalAmount,
    required this.paidAmount,
    required this.balanceDue,
    required this.billsCount,
  });

  factory PayableRecord.fromJson(Map<String, dynamic> json) {
    return PayableRecord(
      supplierId: json['supplier_id'] ?? 0,
      supplierName: json['supplier_name']?.toString() ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      balanceDue: (json['balance_due'] as num?)?.toDouble() ?? 0,
      billsCount: json['bills_count'] ?? 0,
    );
  }
}

class TransactionRecord {
  final String type;
  final int id;
  final String number;
  final String counterparty;
  final double amount;
  final double balanceDue;
  final String status;
  final String date;

  const TransactionRecord({
    required this.type,
    required this.id,
    required this.number,
    required this.counterparty,
    required this.amount,
    required this.balanceDue,
    required this.status,
    required this.date,
  });

  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    return TransactionRecord(
      type: json['type']?.toString() ?? '',
      id: json['id'] ?? 0,
      number: json['number']?.toString() ?? '',
      counterparty: json['counterparty']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      balanceDue: (json['balance_due'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
    );
  }
}

class AccountQuery {
  final int page;
  final int pageSize;
  final String? search;
  final String ordering;
  final String? accountType;
  final bool? isActive;

  const AccountQuery({
    this.page = 1,
    this.pageSize = 12,
    this.search,
    this.ordering = 'code',
    this.accountType,
    this.isActive,
  });

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'page_size': pageSize,
    'search': search,
    'ordering': ordering,
    'account_type': accountType,
    'is_active': isActive,
  }..removeWhere((key, value) => value == null || value == '');
}

class InvoiceQuery {
  final int page;
  final int pageSize;
  final String? search;
  final String ordering;
  final String? status;
  final int? customerId;
  final int? orderId;
  final String? dateFrom;
  final String? dateTo;

  const InvoiceQuery({
    this.page = 1,
    this.pageSize = 12,
    this.search,
    this.ordering = '-created_at',
    this.status,
    this.customerId,
    this.orderId,
    this.dateFrom,
    this.dateTo,
  });

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'page_size': pageSize,
    'search': search,
    'ordering': ordering,
    'status': status,
    'customer_id': customerId,
    'order_id': orderId,
    'date_from': dateFrom,
    'date_to': dateTo,
  }..removeWhere((key, value) => value == null || value == '');
}

class BillQuery {
  final int page;
  final int pageSize;
  final String? search;
  final String ordering;
  final String? status;
  final int? supplierId;
  final int? orderId;
  final String? dateFrom;
  final String? dateTo;

  const BillQuery({
    this.page = 1,
    this.pageSize = 12,
    this.search,
    this.ordering = '-created_at',
    this.status,
    this.supplierId,
    this.orderId,
    this.dateFrom,
    this.dateTo,
  });

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'page_size': pageSize,
    'search': search,
    'ordering': ordering,
    'status': status,
    'supplier_id': supplierId,
    'order_id': orderId,
    'date_from': dateFrom,
    'date_to': dateTo,
  }..removeWhere((key, value) => value == null || value == '');
}

class JournalQuery {
  final int page;
  final int pageSize;
  final String? search;
  final String ordering;
  final String? dateFrom;
  final String? dateTo;

  const JournalQuery({
    this.page = 1,
    this.pageSize = 12,
    this.search,
    this.ordering = '-date',
    this.dateFrom,
    this.dateTo,
  });

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'page_size': pageSize,
    'search': search,
    'ordering': ordering,
    'date_from': dateFrom,
    'date_to': dateTo,
  }..removeWhere((key, value) => value == null || value == '');
}

class PaymentQuery {
  final int page;
  final int pageSize;
  final String? search;
  final String ordering;
  final String? paymentType;
  final String? paymentMethod;
  final int? invoiceId;
  final int? billId;
  final String? dateFrom;
  final String? dateTo;

  const PaymentQuery({
    this.page = 1,
    this.pageSize = 12,
    this.search,
    this.ordering = '-payment_date',
    this.paymentType,
    this.paymentMethod,
    this.invoiceId,
    this.billId,
    this.dateFrom,
    this.dateTo,
  });

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'page_size': pageSize,
    'search': search,
    'ordering': ordering,
    'payment_type': paymentType,
    'payment_method': paymentMethod,
    'invoice_id': invoiceId,
    'bill_id': billId,
    'date_from': dateFrom,
    'date_to': dateTo,
  }..removeWhere((key, value) => value == null || value == '');
}

class ListQuery {
  final int page;
  final int pageSize;
  final String? search;
  final String ordering;

  const ListQuery({
    this.page = 1,
    this.pageSize = 12,
    this.search,
    this.ordering = '-created_at',
  });

  Map<String, dynamic> toQueryParameters() => {
    'page': page,
    'page_size': pageSize,
    'search': search,
    'ordering': ordering,
  }..removeWhere((key, value) => value == null || value == '');
}

class AccountWriteRequest {
  final String name;
  final String? code;
  final String accountType;
  final String? description;
  final bool isActive;

  const AccountWriteRequest({
    required this.name,
    this.code,
    required this.accountType,
    this.description,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code,
    'account_type': accountType,
    'description': description,
    'is_active': isActive,
  }..removeWhere((key, value) => value == null);
}

class PaymentCreateRequest {
  final int? invoiceId;
  final int? billId;
  final double amount;
  final String paymentMethod;
  final String? reference;

  const PaymentCreateRequest({
    this.invoiceId,
    this.billId,
    required this.amount,
    required this.paymentMethod,
    this.reference,
  });

  Map<String, dynamic> toJson() => {
    'invoice_id': invoiceId,
    'bill_id': billId,
    'amount': amount,
    'payment_method': paymentMethod,
    'reference': reference,
  }..removeWhere((key, value) => value == null);
}
