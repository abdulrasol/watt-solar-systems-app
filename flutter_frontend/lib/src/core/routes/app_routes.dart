class AppRoutes {
  // Public
  static const String splash = '/';
  static const String roleSelection = '/role_selection';
  static const String home = '/home';
  static const String featureUnavailable = '/feature-unavailable';
  static const String serviceStatus = '/service-status';
  
  // Auth
  static const String auth = '/auth';
  static const String authProfile = 'profile';
  static const String authEditProfile = 'edit_profile';
  static const String authPasswordReset = 'password-reset';
  static const String authCompanyRegistration = 'company_registration';

  // Core
  static const String settings = '/settings';
  static const String feedback = '/feedback';
  static const String notifications = '/notifications';

  // Admin
  static const String admin = '/admin';
  static const String adminConfigs = '/admin/core/configs';
  static const String adminUsers = '/admin/core/users';
  static const String adminCountries = '/admin/core/countries';
  static const String adminCities = '/admin/core/cities';
  static const String adminCurrencies = '/admin/core/currencies';
  static const String adminSubscriptions = '/admin/core/subscriptions';
  static const String adminCategories = '/admin/core/categories';
  static const String adminCompanies = '/admin/companies';
  static const String adminCompanyDetails = '/admin/companies/:id';
  static const String adminCompanyTypes = '/admin/company-types';
  static const String adminServiceTypes = '/admin/service-types';
  static const String adminInspector = '/admin/inspector';
  static const String adminSubscriptionRequests = '/admin/subscription-requests';
  static const String adminServiceCatalog = '/admin/service-catalog';
  static const String adminSystems = '/admin/ops/systems';
  static const String adminNotifications = '/admin/ops/notifications';
  static const String adminFeedbacks = '/admin/ops/feedbacks';
  static const String adminOffers = '/admin/ops/offers';
  static const String adminPosters = '/admin/ops/posters';
  static const String adminProducts = '/admin/commerce/products';
  static const String adminApiLab = '/admin/tools/api-lab';

  // Company Dashboard
  static const String companyDashboard = '/companies/dashboard';
  static const String companySystems = '/companies/dashboard/systems';
  static const String companySalesOffers = '/companies/dashboard/sales/offers';
  static const String companySalesRequests = '/companies/dashboard/sales/requests';
  static const String companySalesCustomers = '/companies/dashboard/sales/customers';
  static const String companyStorefrontPreview = '/companies/dashboard/sales/storefront-preview';
  
  static const String companyInventoryProducts = '/companies/dashboard/inventory/products';
  static const String companyInventoryProductDetails = '/companies/dashboard/inventory/products/product';
  static const String companyInventoryAdd = '/companies/dashboard/inventory/products/add';
  static const String companyInventoryEdit = '/companies/dashboard/inventory/products/edit';
  static const String companyInventoryCategories = '/companies/dashboard/inventory/categories';
  static const String companyInventorySuppliers = '/companies/dashboard/inventory/suppliers';
  
  static const String companyOrdersList = '/companies/dashboard/orders/list';
  static const String companyOrdersDelivery = '/companies/dashboard/orders/delivery';
  
  static const String companyContentWorks = '/companies/dashboard/content/works';
  static const String companyContentPosters = '/companies/dashboard/content/posters';
  
  static const String companyFinanceExpenses = '/companies/dashboard/finance/expenses';
  static const String companyFinanceAccounting = '/companies/dashboard/finance/accounting';
  
  static const String companySettingsMembers = '/companies/dashboard/settings/members';
  static const String companySettingsContacts = '/companies/dashboard/settings/contacts';
  static const String companySettingsPublicServices = '/companies/dashboard/settings/public-services';
  static const String companySettingsServiceTypes = '/companies/dashboard/settings/service-types';
  static const String companySettingsProfile = '/companies/dashboard/settings/profile';

  // Company Work
  static const String companyWork = '/company-work';
  static const String companyWorkAdd = 'add';
  static const String companyWorkEdit = 'edit/:id';

  // Storefront
  static const String storefrontOrders = '/storefront/:audience/orders';
  static const String storefrontOrderDetails = '/storefront/:audience/orders/:id';
  static const String storefrontOrderResult = '/storefront/order-result';
  static const String storefront = '/storefront';
  static const String storefrontProducts = '/storefront/products';
  static const String storefrontProductDetails = '/storefront/product/:id';
  static const String storefrontCompanies = '/storefront/companies';

  // Calculators & Requests
  static const String userRequests = '/user-requests';
  static const String userRequestsNew = '/user-requests/new';
  static const String calcOfferWizard = '/calculator/request-offer-wizard';
  static const String calcStructureDesign = '/calculator/structure-design';
  static const String calcRoofSimulator = '/calculator/roof-simulator';
  static const String calcPvSystem = '/calculator/pv-system-designer';
  static const String calcFast = '/calculator/fast-calculator';

  // Services & Offers
  static const String members = '/members';
  static const String offers = '/offers';
  static const String offersCatalog = '/offers/catalog';
  static const String adminMarketplace = '/admin-marketplace';
  static const String services = '/services';
  static const String servicesCompanies = '/services/companies';
  static const String servicesCompanyDetails = '/services/company/:id';
}
