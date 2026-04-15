import 'package:flutter/foundation.dart';

class AppUrls {
  // Base URL - Automatically switches based on build mode
  static const String baseUrl = kDebugMode
      ? 'http://127.0.0.1:8000/api/v1'
      : 'https://abdulrasol.pythonanywhere.com/api/v1';

  // ==================== AUTH & USERS ====================
  static const String authBaseUrl = '$baseUrl/users';
  static const String login = '$authBaseUrl/login';
  static const String register = '$authBaseUrl/register';
  static const String profile = '$authBaseUrl/profile';
  static const String passwordReset = '$authBaseUrl/password-reset';
  static const String passwordResetValidateToken =
      '$authBaseUrl/password-reset/validate-token';
  static const String passwordResetConfirm =
      '$authBaseUrl/password-reset/confirm';
  static const String deleteAccount = '$authBaseUrl/delete-account';
  static const String updateLanguage = '$authBaseUrl/language';
  static String userProfile(String username) => '$authBaseUrl/$username';
  static const String allUsers = authBaseUrl; // Admin only
  static String promoteUser(String username) =>
      '$authBaseUrl/promote/$username';

  // ==================== ADMIN ====================
  static const String adminBaseUrl = '$baseUrl/admin';
  static const String feedbacks = '$adminBaseUrl/feedbacks';
  static String feedbackStatus(int id) => '$adminBaseUrl/feedback/s$id';
  static String feedback(int id) => '$adminBaseUrl/feedback/$id';
  static const String appConfigs = '$adminBaseUrl/config';
  static const String currency = '$adminBaseUrl/currency';
  static const String currencies = '$adminBaseUrl/currency'; // Get all
  static String currencyItem(int id) => '$currencies/$id';

  // Cities & Countries
  static const String countries = '$adminBaseUrl/countries';
  static const String cities = '$adminBaseUrl/cities';
  static String country(int id) => '$countries/$id';
  static String city(int id) => '$cities/$id';

  // Companies (Admin)
  static const String companies = '$adminBaseUrl/companies';
  static String companyAdmin(int id) => '$companies/$id';
  static String companyAdminDetails(int id) => '$companies/$id/details';
  static String updateCompanyStatus(int id) => '$companies/$id/status';
  static String companyAdminServices(int id) => '$companies/$id/services';
  static String reviewCompanyService(int companyId, String serviceCode) =>
      '$companies/$companyId/services/$serviceCode/review';

  // Service Catalog (Admin)
  static const String adminServiceCatalog =
      '$adminBaseUrl/companies/catalog/services';
  static String adminServiceCatalogItem(String serviceCode) =>
      '$adminServiceCatalog/$serviceCode';

  // Service Requests (Admin)
  static const String adminServiceRequests =
      '$adminBaseUrl/companies/service-requests';

  // ==================== COMPANIES ====================
  static const String companiesBaseUrl = '$baseUrl/companies';
  static const String registerCompany = '$companiesBaseUrl/register';
  static const String companyTypes = '$companiesBaseUrl/types';
  static const String companySubscriptions = '$companiesBaseUrl/subscriptions';
  static const String companiesCatalogServices =
      '$companiesBaseUrl/catalog/services';
  static const String publicCompanies = '$baseUrl/public/companies';
  static String publicCompany(int id) => '$publicCompanies/$id';

  static String company(int id) => '$companiesBaseUrl/$id';
  static String updateCompany(int id) => company(id);
  static String companySummary(int id) => '${company(id)}/summary';
  static String companyServices(int id) => '${company(id)}/services';
  static String companyServiceRequests(int id) =>
      '${company(id)}/service-requests';
  static String createCompanyServiceRequest(int id) =>
      companyServiceRequests(id);
  static String companySubscriptionRequest(int id) =>
      '${company(id)}/subscription-request';
  static String companyActivationReminder(int id) =>
      '${company(id)}/activation-reminder';
  static String companyMembers(int companyId) =>
      '${company(companyId)}/members';
  static String inviteMember(int companyId) =>
      '${companyMembers(companyId)}/invite';
  static String createNewMember(int companyId) =>
      '${companyMembers(companyId)}/create';
  static String deleteMember(int companyId, int memberId) =>
      '${companyMembers(companyId)}/$memberId';

  // Company Products
  static String products(int companyId) => '${company(companyId)}/products';
  static String productDetails(int companyId, int productId) =>
      '${products(companyId)}/$productId';
  static String deleteProduct(int companyId, int productId) =>
      productDetails(companyId, productId);

  // Company Categories
  static String categories(int companyId) => '${company(companyId)}/categories';
  static String deleteCategory(int companyId, int categoryId) =>
      '${categories(companyId)}/$categoryId';

  // Company Contacts
  static String contacts(int companyId) => '${company(companyId)}/contacts';
  static String deleteContact(int companyId, int contactId) =>
      '${contacts(companyId)}/$contactId';

  // Company Public Services
  static String publicServices(int companyId) =>
      '${company(companyId)}/public-services';
  static String publicService(int companyId, int serviceId) =>
      '${publicServices(companyId)}/$serviceId';

  // Company Delivery Options
  static String deliveryOptions(int companyId) =>
      '${company(companyId)}/delivery';
  static String deleteDeliveryOption(int companyId, int optionId) =>
      '${deliveryOptions(companyId)}/$optionId';

  // Company Expenses
  static String expenses(int companyId) => '${company(companyId)}/expenses';
  static String deleteExpense(int companyId, int expenseId) =>
      '${expenses(companyId)}/$expenseId';

  // Company Finances
  static String finances(int companyId) => '${company(companyId)}/finance';
  static String deleteFinance(int companyId, int financeId) =>
      '${finances(companyId)}/$financeId';
  static String analytics(int companyId) => '${company(companyId)}/analytics';

  // Company Customers / Suppliers / Orders / Systems
  static String customers(int companyId) => '${company(companyId)}/customers';
  static String customer(int companyId, int customerId) =>
      '${customers(companyId)}/$customerId';
  static String suppliers(int companyId) => '${company(companyId)}/suppliers';
  static String supplier(int companyId, int supplierId) =>
      '${suppliers(companyId)}/$supplierId';
  static String orders(int companyId) => '${company(companyId)}/orders';
  static String order(int companyId, int orderId) =>
      '${orders(companyId)}/$orderId';
  static String companySystems(int companyId) =>
      '${company(companyId)}/systems';

  // Company Offers
  static String companyOfferRequests(int companyId) =>
      '${company(companyId)}/offers/requests';
  static String companyOffers(int companyId) => '${company(companyId)}/offers';
  static String createOfferReply(int companyId, int requestId) =>
      '${companyOfferRequests(companyId)}/$requestId/reply';

  // ==================== SHOP ====================
  static const String shopBaseUrl = '$baseUrl/shop';
  static const String shopCatalogMeta = '$shopBaseUrl/catalog/meta';
  static const String storefront = '$shopBaseUrl/frontstore';
  static const String storefrontProducts = '$shopBaseUrl/frontstore/products';
  static const String storefrontCompanies = '$shopBaseUrl/store/companies';
  static String storefrontCompanyCategories(int companyId) =>
      '$shopBaseUrl/store/companies/$companyId/company-categories';
  static const String b2cProducts = '$shopBaseUrl/store/products';
  static const String b2cSearch = '$shopBaseUrl/store/search';
  static const String b2cOrders = '$shopBaseUrl/store/orders';
  static const String b2cMyOrders = '$shopBaseUrl/store/my-orders';
  static String b2cMyOrder(int orderId) => '$b2cMyOrders/$orderId';
  static String cancelB2cMyOrder(int orderId) =>
      '${b2cMyOrder(orderId)}/cancel';
  static String b2cCompanyProducts(int companyId) =>
      '$shopBaseUrl/store/companies/$companyId/products';
  static String b2cCategoryProducts(String categoryType, int categoryId) =>
      '$shopBaseUrl/store/categories/$categoryType/$categoryId/products';
  static const String b2bProducts = '$shopBaseUrl/b2b/products';
  static const String b2bSearch = '$shopBaseUrl/b2b/search';
  static const String b2bOrders = '$shopBaseUrl/b2b/orders';
  static const String b2bMyOrders = '$shopBaseUrl/b2b/my-orders';
  static String b2bMyOrder(int orderId) => '$b2bMyOrders/$orderId';
  static String cancelB2bMyOrder(int orderId) =>
      '${b2bMyOrder(orderId)}/cancel';
  static String confirmB2bMyOrderReceipt(int orderId) =>
      '${b2bMyOrder(orderId)}/confirm-receipt';
  static String b2bCompanyProducts(int companyId) =>
      '$shopBaseUrl/b2b/companies/$companyId/products';
  static String b2bCategoryProducts(String categoryType, int categoryId) =>
      '$shopBaseUrl/b2b/categories/$categoryType/$categoryId/products';
  static String shopProduct(int id) => '$shopBaseUrl/products/$id';

  // ==================== COMMUNITY ====================
  static const String communityBaseUrl = '$baseUrl/community';
  static const String allPosts = '$communityBaseUrl/posts';
  static const String createPost = '$communityBaseUrl/posts/create';
  static String postById(int postId) => '$communityBaseUrl/posts/$postId';
  static String updatePost(int postId) =>
      '$communityBaseUrl/posts/$postId/update';
  static String deletePost(int postId) =>
      '$communityBaseUrl/posts/$postId/delete';
  static String postComments(int postId) =>
      '$communityBaseUrl/posts/$postId/comments';
  static String createComment(int postId) =>
      '$communityBaseUrl/posts/$postId/comments/create';
  static String commentById(int postId, int commentId) =>
      '$communityBaseUrl/posts/$postId/comments/$commentId';
  static String updateComment(int postId, int commentId) =>
      '$communityBaseUrl/posts/$postId/comments/$commentId/update';
  static String deleteComment(int postId, int commentId) =>
      '$communityBaseUrl/posts/$postId/comments/$commentId/delete';
  static String commentReplies(int postId, int commentId) =>
      '$communityBaseUrl/posts/$postId/comments/$commentId/replies';
  static String createReply(int postId, int commentId) =>
      '$communityBaseUrl/posts/$postId/comments/$commentId/replies/create';
  static String replyById(int postId, int commentId, int replyId) =>
      '$communityBaseUrl/posts/$postId/comments/$commentId/replies/$replyId';
  static String deleteReply(int postId, int commentId, int replyId) =>
      '$communityBaseUrl/posts/$postId/comments/$commentId/replies/$replyId/delete';
  static String filteredPosts = '$communityBaseUrl/posts/filter';

  // ==================== ACCOUNTING ====================
  static const String accountingBaseUrl = '$baseUrl/accounting';
  static String accountingOverview(int companyId) =>
      '$accountingBaseUrl/$companyId/overview';
  static String accountingLedger(int companyId) =>
      '$accountingBaseUrl/$companyId/ledger';
  static String accountingAccounts(int companyId) =>
      '$accountingBaseUrl/$companyId/accounts';
  static String accountingAccount(int companyId, int accountId) =>
      '${accountingAccounts(companyId)}/$accountId';
  static String accountingInvoices(int companyId) =>
      '$accountingBaseUrl/$companyId/invoices';
  static String accountingInvoice(int companyId, int invoiceId) =>
      '${accountingInvoices(companyId)}/$invoiceId';
  static String accountingBills(int companyId) =>
      '$accountingBaseUrl/$companyId/bills';
  static String accountingBill(int companyId, int billId) =>
      '${accountingBills(companyId)}/$billId';
  static String accountingPayments(int companyId) =>
      '$accountingBaseUrl/$companyId/payments';
  static String accountingJournal(int companyId) =>
      '$accountingBaseUrl/$companyId/journal';
  static String accountingJournalEntry(int companyId, int entryId) =>
      '${accountingJournal(companyId)}/$entryId';
  static String accountingReceivables(int companyId) =>
      '$accountingBaseUrl/$companyId/receivables';
  static String accountingPayables(int companyId) =>
      '$accountingBaseUrl/$companyId/payables';
  static String accountingTransactions(int companyId) =>
      '$accountingBaseUrl/$companyId/transactions';

  // ==================== SYSTEMS ====================
  static const String systemsBaseUrl = '$baseUrl/systems';
  static const String mySystems = '$systemsBaseUrl/my-systems';
  static String systemDetails(int id) => '$systemsBaseUrl/$id';

  // ==================== NOTIFICATIONS ====================
  static const String notificationBaseUrl = '$baseUrl/notification';
  static const String notificationSubscribe = '$notificationBaseUrl/subscribe';
  static const String notificationUnsubscribe =
      '$notificationBaseUrl/unsubscribe';
  static const String notificationHistory = '$notificationBaseUrl/history';
  static const String notificationDevices = '$notificationBaseUrl/devices';
  static const String notificationSendBroadcast =
      '$notificationBaseUrl/send-broadcast';
  static const String notificationSendTopic = '$notificationBaseUrl/send-topic';
  static const String notificationStatistics =
      '$notificationBaseUrl/statistics';
  static String notificationDeactivateDevice(int deviceId) =>
      '$notificationBaseUrl/tokens/$deviceId/deactivate';

  // ==================== CONFIGURATION ====================
  static const String configBaseUrl = '$baseUrl/config';
  static const String generalConfig = '$configBaseUrl/general';
  static const String siteConfig = '$configBaseUrl/site';

  // ==================== OFFERS & REQUESTS (MARKETPLACE) ====================

  static const String _offersBaseUrl = '$baseUrl/offers';
  static const String requestsBaseUrl = '$_offersBaseUrl/requests';
  static const String availableRequests = '$_offersBaseUrl/available-requests';
  static const String myOffers = '$_offersBaseUrl/my-offers';

  // User Interface
  static const String createRequest = requestsBaseUrl;
  static const String userRequests = requestsBaseUrl;
  static String deleteRequest(int id) => '$requestsBaseUrl/$id';
  static String requestOffers(int requestId) =>
      '$requestsBaseUrl/$requestId/offers';
  static String respondToOffer(int offerId) =>
      '$_offersBaseUrl/$offerId/response';

  // Company Interface
  static String replyToRequest(int requestId) =>
      '$requestsBaseUrl/$requestId/reply';
  static String finishOffer(int offerId) => '$myOffers/$offerId/finish';
  static String offerDetails(int offerId) => '$myOffers/$offerId';
  static String updateOffer(int offerId) => offerDetails(offerId);
  static String deleteOffer(int offerId) => offerDetails(offerId);
  static const String involves = '$baseUrl/involves';
  static String involve(int id) => '$involves/$id';

  // Admin Interface
  static const String adminOffers = '$baseUrl/offers/admin/offers';
  static const String adminRequests = '$baseUrl/offers/admin/requests';
}
