/// Typed feature keys used across the app for dynamically enabling or disabling sections.
///
/// These map directly to the keys returned by the backend's `/api/v1/admin/config` endpoint.
enum AppFeature {
  // Global / Authentication
  auth('auth', 'Login & Registration'),
  posters('posters', 'App Posters / Banners'),
  notifications('notifications', 'In-app Notifications'),
  systems('systems', 'Systems Feature'),

  // User Dashboard & Calculators
  userRequests('user_requests', 'User Requests list and form'),
  feedback('feedback', 'User Feedback submission'),
  calculatorStructure('calculator_structure', 'Structure Design Tool'),
  calculatorRoof('calculator_roof', 'Roof Simulator Tool'),
  calculatorPv('calculator_pv', 'PV System Designer'),
  calculatorFast('calculator_fast', 'Fast Calculator'),
  store('store', 'Storefront for end users'),
  services('services', 'Companies / Services Directory'),
  community('community', 'Community feature'),

  // Company Dashboard
  companies('companies', 'Companies list/directory'),
  company('company', 'Company dashboard access'),
  companySales('company_sales', 'Entire sales section'),
  offers('offers', 'Offers management'),
  companyCrm('company_crm', 'Customers / CRM'),
  companyInventory('company_inventory', 'Entire inventory section'),
  companyProducts('company_products', 'Products management'),
  companyOrders('company_orders', 'Entire orders section'),
  companyFinance('company_finance', 'Entire finance section'),
  companyContent('company_content', 'Company works/projects portfolio'),
  companyMembers('company_members', 'Team members management');

  const AppFeature(this.key, this.description);

  /// The string key returned by the backend API.
  final String key;
  
  /// A brief explanation of what the feature controls.
  final String description;

  /// Looks up an [AppFeature] by its remote string key.
  static AppFeature? fromKey(String key) {
    for (final feature in values) {
      if (feature.key == key) return feature;
    }
    return null;
  }
}
