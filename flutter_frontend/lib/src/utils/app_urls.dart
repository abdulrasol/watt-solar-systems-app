import 'package:flutter/foundation.dart';

class AppUrls {
  // Base URL - Automatically switches based on build mode and platform
  static String get baseUrl {
    if (kReleaseMode) {
      // return 'https://watt-mu0i.onrender.com/api/v1';
      return 'https://192.168.1.107/api/v1';
    }
    // For Debug Mode:
    // 10.0.2.2 is the special alias to your host loopback interface in Android Emulator.
    // iOS Simulator and desktop builds use 127.0.0.1.
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://192.168.1.100/api/v1';
      }
    } catch (_) {}
    return 'http://192.168.1.100/api/v1';
  }

  // Resolves media path (e.g. /uploads/...) to full URL
  static String resolveMediaUrl(String path) {
    if (path.isEmpty || path == 'null') return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;

    final baseServerUrl = baseUrl.replaceAll('/api/v1', '');
    if (!path.startsWith('/')) path = '/$path';
    return '$baseServerUrl$path';
  }

  // ==================== AUTH & USERS ====================
  static String get authBaseUrl => '$baseUrl/users';
  static String get login => '$authBaseUrl/login';
  static String get register => '$authBaseUrl/register';
  static String get profile => '$authBaseUrl/profile';
  static String get passwordReset => '$authBaseUrl/password-reset';
  static String get passwordResetValidateToken => '$authBaseUrl/password-reset/validate-token';
  static String get passwordResetConfirm => '$authBaseUrl/password-reset/confirm';
  static String get deleteAccount => '$authBaseUrl/delete-account';
  static String get updateLanguage => '$authBaseUrl/language';
  static String userProfile(String username) => '$authBaseUrl/$username';
  static String get allUsers => authBaseUrl; // Admin only
  static String promoteUser(String username) => '$authBaseUrl/promote/$username';

  // ==================== ADMIN ====================
  static String get adminBaseUrl => '$baseUrl/admin';
  static String get feedbacks => '$adminBaseUrl/feedbacks';
  static String feedbackStatus(int id) => '$adminBaseUrl/feedback/s$id';
  static String feedback(int id) => '$adminBaseUrl/feedback/$id';
  static String get appConfigs => '$adminBaseUrl/config';
  static String get currencies => '$adminBaseUrl/currencies';
  static String currency(int id) => '$currencies/$id';
  static String get globalCategories => '$adminBaseUrl/categories';
  static String globalCategory(int id) => '$globalCategories/$id';
  // Admin Subscriptions
  static String get adminSubscriptions => '$adminBaseUrl/subscriptions';
  static String adminSubscription(int id) => '$adminSubscriptions/$id';
  static String get adminSubscriptionRequests => '$companies/subscription-requests';
  static String adminReviewSubscriptionRequest(int companyId, int requestId) => '$companies/$companyId/subscription-requests/$requestId/review';
  static String get adminProducts => '$adminBaseUrl/shop/products';
  static String adminProduct(int id) => '$adminProducts/$id';
  static String get adminSystems => '$adminBaseUrl/systems';
  static String adminSystemStatus(int id) => '$adminSystems/$id/status';

  // Cities & Countries
  static String get countries => '$adminBaseUrl/countries';
  static String get cities => '$adminBaseUrl/cities';
  static String country(int id) => '$countries/$id';
  static String city(int id) => '$cities/$id';

  // Companies (Admin)
  static String get companies => '$adminBaseUrl/companies';
  static String companyAdmin(int id) => '$companies/$id';
  static String companyAdminDetails(int id) => '$companies/$id/details';
  static String updateCompanyStatus(int id) => '$companies/$id/status';
  static String companyAdminServices(int id) => '$companies/$id/services';
  static String get adminCompanyTypes => '$adminBaseUrl/companies/types';
  static String adminCompanyType(int id) => '$adminCompanyTypes/$id';

  // ==================== COMPANIES ====================
  static String get companiesBaseUrl => '$baseUrl/companies';
  static String get registerCompany => '$companiesBaseUrl/register';
  static String get companyTypes => '$companiesBaseUrl/types';
  static String get serviceTypes => '$baseUrl/service-types';
  static String get serviceTypesPublic => '$serviceTypes/public';
  static String serviceType(int id) => '$serviceTypes/$id';
  static String toggleServiceType(int id) => '${serviceType(id)}/toggle';
  static String get companySubscriptions => '$companiesBaseUrl/subscriptions';
  static String get publicCompanies => '$baseUrl/public/companies';
  static String publicCompany(int id) => '$publicCompanies/$id';

  static String company(int id) => '$companiesBaseUrl/$id';
  static String updateCompany(int id) => company(id);
  static String companySummary(int id) => '${company(id)}/summary';
  static String companyServices(int id) => '${company(id)}/services';
  static String companySubscriptionRequest(int id) => '${company(id)}/subscription-request';
  static String companyActivationReminder(int id) => '${company(id)}/activation-reminder';
  static String companyMembers(int companyId) => '${company(companyId)}/members';
  static String inviteMember(int companyId) => '${companyMembers(companyId)}/invite';
  static String createNewMember(int companyId) => '${companyMembers(companyId)}/create';
  static String deleteMember(int companyId, int memberId) => '${companyMembers(companyId)}/$memberId';
  static String companyActivity(int companyId) => '${company(companyId)}/activity';

  // Company Products
  static String products(int companyId) => '${company(companyId)}/products';
  static String productDetails(int companyId, int productId) => '${products(companyId)}/$productId';
  static String deleteProduct(int companyId, int productId) => productDetails(companyId, productId);

  // Company Categories
  static String categories(int companyId) => '${company(companyId)}/categories';
  static String deleteCategory(int companyId, int categoryId) => '${categories(companyId)}/$categoryId';

  // Company Contacts
  static String contacts(int companyId) => '${company(companyId)}/contacts';
  static String deleteContact(int companyId, int contactId) => '${contacts(companyId)}/$contactId';

  // Company Public Services
  static String publicServices(int companyId) => '${company(companyId)}/public-services';
  static String publicService(int companyId, int serviceId) => '${publicServices(companyId)}/$serviceId';

  // Company Delivery Options
  static String deliveryOptions(int companyId) => '${company(companyId)}/delivery';
  static String deleteDeliveryOption(int companyId, int optionId) => '${deliveryOptions(companyId)}/$optionId';

  // Company Expenses
  // NOTE: backend route is singular `/expense` (see companies/api.py
  // `api_list_expense`/`api_create_expense`/`api_delete_expense`) — this
  // helper previously pointed at `/expenses` (plural), which would 404
  // against the real API. Fixed to match the backend exactly.
  static String expenses(int companyId) => '${company(companyId)}/expense';
  static String deleteExpense(int companyId, int expenseId) => '${expenses(companyId)}/$expenseId';

  // Company Finances
  static String finances(int companyId) => '${company(companyId)}/finance';
  static String deleteFinance(int companyId, int financeId) => '${finances(companyId)}/$financeId';
  static String analytics(int companyId) => '${company(companyId)}/analytics';

  // Company Customers / Suppliers / Orders / Systems
  static String customers(int companyId) => '${company(companyId)}/customers';
  static String customer(int companyId, int customerId) => '${customers(companyId)}/$customerId';
  static String suppliers(int companyId) => '${company(companyId)}/suppliers';
  static String supplier(int companyId, int supplierId) => '${suppliers(companyId)}/$supplierId';
  static String orders(int companyId) => '${company(companyId)}/orders';
  static String order(int companyId, int orderId) => '${orders(companyId)}/$orderId';
  static String companySystems(int companyId) => '${company(companyId)}/systems';

  // Company Offers
  static String companyOfferRequests(int companyId) => '${company(companyId)}/offers/requests';
  static String companyOffers(int companyId) => '${company(companyId)}/offers';
  static String createOfferReply(int companyId, int requestId) => '${companyOfferRequests(companyId)}/$requestId/reply';
  static String companyWorks(int companyId) => '${company(companyId)}/works';
  static String companyWork(int companyId, int workId) => '${companyWorks(companyId)}/$workId';
  static String companyWorkImage(int companyId, int imageId) => '${company(companyId)}/works/image/$imageId';
  static String publicCompanyWorks(int companyId) => '$publicCompanies/$companyId/works';

  // Company Posters
  static String companyPosters(int companyId) => '${company(companyId)}/posters';
  static String companyPoster(int companyId, int posterId) => '${companyPosters(companyId)}/$posterId';
  static String companyPosterToggle(int companyId, int posterId) => '${companyPoster(companyId, posterId)}/toggle-active';

  // Public Posters
  static String get activePosters => '$publicCompanies/posters';

  // Admin Posters
  static String get adminPosters => '$companies/posters';
  static String adminPosterReview(int id) => '$adminPosters/$id/review';
  static String adminPosterExtend(int id) => '$adminPosters/$id/extend';

  // ==================== SHOP ====================
  static String get shopBaseUrl => '$baseUrl/shop';
  static String get shopCartValidate => '$shopBaseUrl/cart/validate';
  static String get shopCatalogMeta => '$shopBaseUrl/catalog/meta';
  static String get storefront => '$shopBaseUrl/frontstore';
  static String get storefrontProducts => '$shopBaseUrl/frontstore/products';
  static String get storefrontCompanies => '$shopBaseUrl/store/companies';
  static String storefrontCompanyCategories(int companyId) => '$shopBaseUrl/store/companies/$companyId/company-categories';
  static String get b2cProducts => '$shopBaseUrl/store/products';
  static String b2cProduct(int id) => '$shopBaseUrl/store/products/$id';
  static String get b2cSearch => '$shopBaseUrl/store/search';
  static String get b2cOrders => '$shopBaseUrl/store/orders';
  static String get b2cMyOrders => '$shopBaseUrl/store/my-orders';
  static String b2cMyOrder(int orderId) => '$b2cMyOrders/$orderId';
  static String cancelB2cMyOrder(int orderId) => '${b2cMyOrder(orderId)}/cancel';
  static String b2cCompanyProducts(int companyId) => '$shopBaseUrl/store/companies/$companyId/products';
  static String b2cCategoryProducts(String categoryType, int categoryId) => '$shopBaseUrl/store/categories/$categoryType/$categoryId/products';
  static String get b2bProducts => '$shopBaseUrl/b2b/products';
  static String b2bProduct(int id) => '$shopBaseUrl/b2b/products/$id';
  static String get b2bSearch => '$shopBaseUrl/b2b/search';
  static String get b2bOrders => '$shopBaseUrl/b2b/orders';
  static String get b2bMyOrders => '$shopBaseUrl/b2b/my-orders';
  static String b2bMyOrder(int orderId) => '$b2bMyOrders/$orderId';
  static String cancelB2bMyOrder(int orderId) => '${b2bMyOrder(orderId)}/cancel';
  static String confirmB2bMyOrderReceipt(int orderId) => '${b2bMyOrder(orderId)}/confirm-receipt';
  static String b2bCompanyProducts(int companyId) => '$shopBaseUrl/b2b/companies/$companyId/products';
  static String b2bCategoryProducts(String categoryType, int categoryId) => '$shopBaseUrl/b2b/categories/$categoryType/$categoryId/products';
  static String shopProduct(int id) => '$shopBaseUrl/products/$id';

  // ==================== COMMUNITY ====================
  static String get communityBaseUrl => '$baseUrl/community';

  // Posts
  static String get posts => '$communityBaseUrl/posts/'; // GET, POST
  static String postById(int postId) => '$communityBaseUrl/posts/$postId'; // GET, PUT, DELETE

  // Comments
  static String postComments(int postId) => '$communityBaseUrl/posts/$postId/comments'; // GET, POST
  static String commentById(int commentId) => '$communityBaseUrl/comments/$commentId'; // PUT, DELETE

  // ==================== ACCOUNTING ====================
  static String get accountingBaseUrl => '$baseUrl/accounting';
  static String accountingOverview(int companyId) => '$accountingBaseUrl/$companyId/overview';
  static String accountingLedger(int companyId) => '$accountingBaseUrl/$companyId/ledger';
  static String accountingAccounts(int companyId) => '$accountingBaseUrl/$companyId/accounts';
  static String accountingAccount(int companyId, int accountId) => '${accountingAccounts(companyId)}/$accountId';
  static String accountingInvoices(int companyId) => '$accountingBaseUrl/$companyId/invoices';
  static String accountingInvoice(int companyId, int invoiceId) => '${accountingInvoices(companyId)}/$invoiceId';
  static String accountingBills(int companyId) => '$accountingBaseUrl/$companyId/bills';
  static String accountingBill(int companyId, int billId) => '${accountingBills(companyId)}/$billId';
  static String accountingPayments(int companyId) => '$accountingBaseUrl/$companyId/payments';
  static String accountingJournal(int companyId) => '$accountingBaseUrl/$companyId/journal';
  static String accountingJournalEntry(int companyId, int entryId) => '${accountingJournal(companyId)}/$entryId';
  static String accountingReceivables(int companyId) => '$accountingBaseUrl/$companyId/receivables';
  static String accountingPayables(int companyId) => '$accountingBaseUrl/$companyId/payables';
  static String accountingTransactions(int companyId) => '$accountingBaseUrl/$companyId/transactions';

  // ==================== SYSTEMS ====================
  static String get systemsBaseUrl => '$baseUrl/systems';
  static String get mySystems => '$systemsBaseUrl/my-systems';
  static String systemDetails(int id) => '$systemsBaseUrl/$id';

  // ==================== NOTIFICATIONS ====================
  static String get notificationBaseUrl => '$baseUrl/notification';
  static String get notificationSubscribe => '$notificationBaseUrl/subscribe';
  static String get notificationUnsubscribe => '$notificationBaseUrl/unsubscribe';
  static String get notificationHistory => '$notificationBaseUrl/history';
  static String get notificationDevices => '$notificationBaseUrl/devices';
  static String get notificationSendBroadcast => '$notificationBaseUrl/send-broadcast';
  static String get notificationSendTopic => '$notificationBaseUrl/send-topic';
  static String get notificationSendGroup => '$notificationBaseUrl/send-group';
  static String get notificationSendUser => '$notificationBaseUrl/send-user';
  static String get notificationStatistics => '$notificationBaseUrl/statistics';
  static String notificationDeactivateDevice(int deviceId) => '$notificationBaseUrl/tokens/$deviceId/deactivate';

  // ==================== CONFIGURATION ====================
  static String get configBaseUrl => '$baseUrl/config';
  static String get generalConfig => '$configBaseUrl/general';
  static String get siteConfig => '$configBaseUrl/site';

  // ==================== OFFERS & REQUESTS (MARKETPLACE) ====================

  static String get _offersBaseUrl => '$baseUrl/offers';
  static String get requestsBaseUrl => '$_offersBaseUrl/requests';
  static String get availableRequests => '$_offersBaseUrl/available-requests';
  static String get myOffers => '$_offersBaseUrl/my-offers';

  // User Interface
  static String get createRequest => requestsBaseUrl;
  static String get userRequests => requestsBaseUrl;
  static String deleteRequest(int id) => '$requestsBaseUrl/$id';
  static String requestOffers(int requestId) => '$requestsBaseUrl/$requestId/offers';
  static String respondToOffer(int offerId) => '$_offersBaseUrl/$offerId/response';

  // Company Interface
  static String replyToRequest(int requestId) => '$requestsBaseUrl/$requestId/reply';
  static String finishOffer(int offerId) => '$myOffers/$offerId/finish';
  static String offerDetails(int offerId) => '$myOffers/$offerId';
  static String updateOffer(int offerId) => offerDetails(offerId);
  static String deleteOffer(int offerId) => offerDetails(offerId);
  static String get involves => '$baseUrl/involves';
  static String involve(int id) => '$involves/$id';

  // Admin Interface
  static String get adminOffers => '$baseUrl/offers/admin/offers';
  static String get adminRequests => '$baseUrl/offers/admin/requests';
}
