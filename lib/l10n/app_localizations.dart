import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Watt'**
  String get app_name;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @app_slug.
  ///
  /// In en, this message translates to:
  /// **'Calculate Your Solar System'**
  String get app_slug;

  /// No description provided for @app_name_short.
  ///
  /// In en, this message translates to:
  /// **'Watt'**
  String get app_name_short;

  /// No description provided for @app_slug_short.
  ///
  /// In en, this message translates to:
  /// **'Calculate Your Solar System'**
  String get app_slug_short;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @my_systems.
  ///
  /// In en, this message translates to:
  /// **'My Systems'**
  String get my_systems;

  /// No description provided for @my_requests.
  ///
  /// In en, this message translates to:
  /// **'My Requests'**
  String get my_requests;

  /// No description provided for @my_orders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get my_orders;

  /// No description provided for @company_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Company Workspace'**
  String get company_dashboard;

  /// No description provided for @admin_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Workspace'**
  String get admin_dashboard;

  /// No description provided for @register_company.
  ///
  /// In en, this message translates to:
  /// **'Register Company'**
  String get register_company;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @guest_user.
  ///
  /// In en, this message translates to:
  /// **'Guest User'**
  String get guest_user;

  /// No description provided for @welcome_guest.
  ///
  /// In en, this message translates to:
  /// **'Welcome, guest'**
  String get welcome_guest;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello,'**
  String get hello;

  /// No description provided for @dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get dark_mode;

  /// No description provided for @sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get sign_out;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get sign_in;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @good_morning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get good_morning;

  /// No description provided for @good_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get good_afternoon;

  /// No description provided for @good_evening.
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get good_evening;

  /// No description provided for @good_night.
  ///
  /// In en, this message translates to:
  /// **'Good night,'**
  String get good_night;

  /// No description provided for @ready_to_manage_solar.
  ///
  /// In en, this message translates to:
  /// **'Ready to manage your solar systems?'**
  String get ready_to_manage_solar;

  /// No description provided for @active_orders.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get active_orders;

  /// No description provided for @quick_actions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quick_actions;

  /// No description provided for @calculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculator;

  /// No description provided for @plan_your_system.
  ///
  /// In en, this message translates to:
  /// **'Plan your system'**
  String get plan_your_system;

  /// No description provided for @solar_tips.
  ///
  /// In en, this message translates to:
  /// **'Solar Tips & Hints'**
  String get solar_tips;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @dashboard_hero_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Start with a quick estimate, prepare an offer request, or explore components for your next solar setup.'**
  String get dashboard_hero_subtitle;

  /// No description provided for @dashboard_chip_fast.
  ///
  /// In en, this message translates to:
  /// **'Fast sizing'**
  String get dashboard_chip_fast;

  /// No description provided for @dashboard_chip_offers.
  ///
  /// In en, this message translates to:
  /// **'Offer ready'**
  String get dashboard_chip_offers;

  /// No description provided for @dashboard_chip_store.
  ///
  /// In en, this message translates to:
  /// **'Shop parts'**
  String get dashboard_chip_store;

  /// No description provided for @dashboard_quick_actions_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Jump directly into the calculator flow that matches your job.'**
  String get dashboard_quick_actions_subtitle;

  /// No description provided for @dashboard_fast_calculator.
  ///
  /// In en, this message translates to:
  /// **'Fast Calculator'**
  String get dashboard_fast_calculator;

  /// No description provided for @dashboard_fast_calculator_desc.
  ///
  /// In en, this message translates to:
  /// **'Estimate panels, inverter size, and battery storage from a few direct inputs.'**
  String get dashboard_fast_calculator_desc;

  /// No description provided for @dashboard_offer_wizard.
  ///
  /// In en, this message translates to:
  /// **'Offer Request Wizard'**
  String get dashboard_offer_wizard;

  /// No description provided for @dashboard_offer_wizard_desc.
  ///
  /// In en, this message translates to:
  /// **'Prepare a structured request for panels, inverter, and batteries before sending it.'**
  String get dashboard_offer_wizard_desc;

  /// No description provided for @dashboard_system_wizard.
  ///
  /// In en, this message translates to:
  /// **'System Calculator Wizard'**
  String get dashboard_system_wizard;

  /// No description provided for @dashboard_system_wizard_desc.
  ///
  /// In en, this message translates to:
  /// **'Build a fuller solar system design using appliances, usage, and system preferences.'**
  String get dashboard_system_wizard_desc;

  /// No description provided for @dashboard_shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get dashboard_shopping;

  /// No description provided for @dashboard_shopping_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse available products now and keep room for featured items later.'**
  String get dashboard_shopping_subtitle;

  /// No description provided for @dashboard_shop_now.
  ///
  /// In en, this message translates to:
  /// **'Open Store'**
  String get dashboard_shop_now;

  /// No description provided for @dashboard_shop_now_desc.
  ///
  /// In en, this message translates to:
  /// **'Move to the storefront tab and start browsing solar components.'**
  String get dashboard_shop_now_desc;

  /// No description provided for @dashboard_featured_products.
  ///
  /// In en, this message translates to:
  /// **'Featured Picks'**
  String get dashboard_featured_products;

  /// No description provided for @dashboard_featured_products_desc.
  ///
  /// In en, this message translates to:
  /// **'Reserved for curated products and bundles after the next API integration.'**
  String get dashboard_featured_products_desc;

  /// No description provided for @dashboard_store_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Store access is currently unavailable on this device.'**
  String get dashboard_store_coming_soon;

  /// No description provided for @dashboard_open_store.
  ///
  /// In en, this message translates to:
  /// **'Open store'**
  String get dashboard_open_store;

  /// No description provided for @dashboard_placeholder_badge.
  ///
  /// In en, this message translates to:
  /// **'Placeholder'**
  String get dashboard_placeholder_badge;

  /// No description provided for @dashboard_promotions.
  ///
  /// In en, this message translates to:
  /// **'Company Posters'**
  String get dashboard_promotions;

  /// No description provided for @dashboard_promotions_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Temporary slides now, ready for company campaigns and poster APIs later.'**
  String get dashboard_promotions_subtitle;

  /// No description provided for @dashboard_poster_title_1.
  ///
  /// In en, this message translates to:
  /// **'Brand campaign slot'**
  String get dashboard_poster_title_1;

  /// No description provided for @dashboard_poster_desc_1.
  ///
  /// In en, this message translates to:
  /// **'Company banners, launch offers, and seasonal promotions will appear here.'**
  String get dashboard_poster_desc_1;

  /// No description provided for @dashboard_poster_title_2.
  ///
  /// In en, this message translates to:
  /// **'Installer spotlight'**
  String get dashboard_poster_title_2;

  /// No description provided for @dashboard_poster_desc_2.
  ///
  /// In en, this message translates to:
  /// **'Use this space later for partner highlights, service coverage, or campaign banners.'**
  String get dashboard_poster_desc_2;

  /// No description provided for @dashboard_poster_title_3.
  ///
  /// In en, this message translates to:
  /// **'New arrivals banner'**
  String get dashboard_poster_title_3;

  /// No description provided for @dashboard_poster_desc_3.
  ///
  /// In en, this message translates to:
  /// **'Upcoming APIs can feed this carousel with new stock, featured kits, or limited offers.'**
  String get dashboard_poster_desc_3;

  /// No description provided for @dashboard_tips_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Practical reminders to size better, buy smarter, and avoid avoidable system mistakes.'**
  String get dashboard_tips_subtitle;

  /// No description provided for @dashboard_hint_clean_title.
  ///
  /// In en, this message translates to:
  /// **'Keep panels clean'**
  String get dashboard_hint_clean_title;

  /// No description provided for @dashboard_hint_clean_desc.
  ///
  /// In en, this message translates to:
  /// **'Dust and shading quickly reduce solar output. A simple cleaning plan can improve production consistency.'**
  String get dashboard_hint_clean_desc;

  /// No description provided for @dashboard_hint_expand_title.
  ///
  /// In en, this message translates to:
  /// **'Leave room to expand'**
  String get dashboard_hint_expand_title;

  /// No description provided for @dashboard_hint_expand_desc.
  ///
  /// In en, this message translates to:
  /// **'When sizing an inverter or battery bank, consider future loads so the system does not become tight too early.'**
  String get dashboard_hint_expand_desc;

  /// No description provided for @dashboard_hint_compare_title.
  ///
  /// In en, this message translates to:
  /// **'Compare before you buy'**
  String get dashboard_hint_compare_title;

  /// No description provided for @dashboard_hint_compare_desc.
  ///
  /// In en, this message translates to:
  /// **'Use the calculators first, then compare offers and components against the same target system size.'**
  String get dashboard_hint_compare_desc;

  /// No description provided for @buy_components.
  ///
  /// In en, this message translates to:
  /// **'Buy components'**
  String get buy_components;

  /// No description provided for @b2b_storefront.
  ///
  /// In en, this message translates to:
  /// **'B2B Storefront'**
  String get b2b_storefront;

  /// No description provided for @b2c_storefront.
  ///
  /// In en, this message translates to:
  /// **'B2C Storefront'**
  String get b2c_storefront;

  /// No description provided for @storefront_b2b_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Member-only catalog with wholesale pricing and company inventory visibility.'**
  String get storefront_b2b_subtitle;

  /// No description provided for @storefront_b2c_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Open storefront for all users with public product access.'**
  String get storefront_b2c_subtitle;

  /// No description provided for @storefront_products_available.
  ///
  /// In en, this message translates to:
  /// **'{count} products available'**
  String storefront_products_available(Object count);

  /// No description provided for @search_products.
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get search_products;

  /// No description provided for @search_b2b_products.
  ///
  /// In en, this message translates to:
  /// **'Search B2B products'**
  String get search_b2b_products;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @sort_by.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sort_by;

  /// No description provided for @sort_newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sort_newest;

  /// No description provided for @sort_oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get sort_oldest;

  /// No description provided for @sort_name_asc.
  ///
  /// In en, this message translates to:
  /// **'Name A-Z'**
  String get sort_name_asc;

  /// No description provided for @sort_name_desc.
  ///
  /// In en, this message translates to:
  /// **'Name Z-A'**
  String get sort_name_desc;

  /// No description provided for @sort_price_asc.
  ///
  /// In en, this message translates to:
  /// **'Price Low-High'**
  String get sort_price_asc;

  /// No description provided for @sort_price_desc.
  ///
  /// In en, this message translates to:
  /// **'Price High-Low'**
  String get sort_price_desc;

  /// No description provided for @sort_retail_price_asc.
  ///
  /// In en, this message translates to:
  /// **'Retail Price Low-High'**
  String get sort_retail_price_asc;

  /// No description provided for @sort_retail_price_desc.
  ///
  /// In en, this message translates to:
  /// **'Retail Price High-Low'**
  String get sort_retail_price_desc;

  /// No description provided for @sort_wholesale_price_asc.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Price Low-High'**
  String get sort_wholesale_price_asc;

  /// No description provided for @sort_wholesale_price_desc.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Price High-Low'**
  String get sort_wholesale_price_desc;

  /// No description provided for @sort_stock_asc.
  ///
  /// In en, this message translates to:
  /// **'Stock Low-High'**
  String get sort_stock_asc;

  /// No description provided for @sort_stock_desc.
  ///
  /// In en, this message translates to:
  /// **'Stock High-Low'**
  String get sort_stock_desc;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @all_categories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get all_categories;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @cancel_action.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel_action;

  /// No description provided for @delete_action.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete_action;

  /// No description provided for @all_companies.
  ///
  /// In en, this message translates to:
  /// **'All companies'**
  String get all_companies;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @min_price.
  ///
  /// In en, this message translates to:
  /// **'Min price'**
  String get min_price;

  /// No description provided for @max_price.
  ///
  /// In en, this message translates to:
  /// **'Max price'**
  String get max_price;

  /// No description provided for @clear_filters.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear_filters;

  /// No description provided for @apply_filters.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply_filters;

  /// No description provided for @store_filters.
  ///
  /// In en, this message translates to:
  /// **'Store Filters'**
  String get store_filters;

  /// No description provided for @no_store_products_found.
  ///
  /// In en, this message translates to:
  /// **'No products matched the current filters.'**
  String get no_store_products_found;

  /// No description provided for @load_more.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get load_more;

  /// No description provided for @global_category.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get global_category;

  /// No description provided for @internal_category.
  ///
  /// In en, this message translates to:
  /// **'Internal'**
  String get internal_category;

  /// No description provided for @company_category.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company_category;

  /// No description provided for @iqd_price.
  ///
  /// In en, this message translates to:
  /// **'IQD {amount}'**
  String iqd_price(Object amount);

  /// No description provided for @retail_price_label.
  ///
  /// In en, this message translates to:
  /// **'Retail {amount}'**
  String retail_price_label(Object amount);

  /// No description provided for @wholesale_price_label.
  ///
  /// In en, this message translates to:
  /// **'Wholesale {amount}'**
  String wholesale_price_label(Object amount);

  /// No description provided for @stock_count.
  ///
  /// In en, this message translates to:
  /// **'Stock {count}'**
  String stock_count(Object count);

  /// No description provided for @product_details.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get product_details;

  /// No description provided for @price_overview.
  ///
  /// In en, this message translates to:
  /// **'Price Overview'**
  String get price_overview;

  /// No description provided for @display_price.
  ///
  /// In en, this message translates to:
  /// **'Display Price'**
  String get display_price;

  /// No description provided for @retail_price.
  ///
  /// In en, this message translates to:
  /// **'Retail Price'**
  String get retail_price;

  /// No description provided for @wholesale_price.
  ///
  /// In en, this message translates to:
  /// **'Wholesale Price'**
  String get wholesale_price;

  /// No description provided for @sku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get sku;

  /// No description provided for @pricing_tiers.
  ///
  /// In en, this message translates to:
  /// **'Pricing Tiers'**
  String get pricing_tiers;

  /// No description provided for @pricing_tier_line.
  ///
  /// In en, this message translates to:
  /// **'{quantity}+ units: IQD {amount}'**
  String pricing_tier_line(Object quantity, Object amount);

  /// No description provided for @add_to_cart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get add_to_cart;

  /// No description provided for @added_to_cart.
  ///
  /// In en, this message translates to:
  /// **'Added to cart'**
  String get added_to_cart;

  /// No description provided for @b2b_cart.
  ///
  /// In en, this message translates to:
  /// **'B2B Cart'**
  String get b2b_cart;

  /// No description provided for @b2c_cart.
  ///
  /// In en, this message translates to:
  /// **'B2C Cart'**
  String get b2c_cart;

  /// No description provided for @cart_empty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cart_empty;

  /// No description provided for @cart_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Add products from the storefront to create a local cart for each company.'**
  String get cart_empty_subtitle;

  /// No description provided for @cart_summary.
  ///
  /// In en, this message translates to:
  /// **'Cart Summary'**
  String get cart_summary;

  /// No description provided for @total_items.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get total_items;

  /// No description provided for @total_amount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get total_amount;

  /// No description provided for @cart_items_count.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String cart_items_count(Object count);

  /// No description provided for @clear_cart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get clear_cart;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @join_community.
  ///
  /// In en, this message translates to:
  /// **'Join the Community'**
  String get join_community;

  /// No description provided for @share_system_feedback.
  ///
  /// In en, this message translates to:
  /// **'Share your system & get feedback'**
  String get share_system_feedback;

  /// No description provided for @reset_password.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get reset_password;

  /// No description provided for @reset_password_instructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you a link to reset your password.'**
  String get reset_password_instructions;

  /// No description provided for @reset_password_token_instructions.
  ///
  /// In en, this message translates to:
  /// **'Enter the token you received and choose a new password.'**
  String get reset_password_token_instructions;

  /// No description provided for @email_is_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get email_is_required;

  /// No description provided for @invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get invalid_email;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @password_reset_email_sent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent!'**
  String get password_reset_email_sent;

  /// No description provided for @password_reset_success.
  ///
  /// In en, this message translates to:
  /// **'Your password has been reset successfully.'**
  String get password_reset_success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @send_reset_link.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get send_reset_link;

  /// No description provided for @reset_token.
  ///
  /// In en, this message translates to:
  /// **'Reset Token'**
  String get reset_token;

  /// No description provided for @reset_token_required.
  ///
  /// In en, this message translates to:
  /// **'Reset token is required'**
  String get reset_token_required;

  /// No description provided for @verify_token.
  ///
  /// In en, this message translates to:
  /// **'Verify Token'**
  String get verify_token;

  /// No description provided for @reset_token_verified.
  ///
  /// In en, this message translates to:
  /// **'Token verified successfully.'**
  String get reset_token_verified;

  /// No description provided for @new_password.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get new_password;

  /// No description provided for @confirm_new_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirm_new_password;

  /// No description provided for @delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get delete_account;

  /// No description provided for @delete_account_warning.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent. Enter your password to delete your account.'**
  String get delete_account_warning;

  /// No description provided for @delete_account_reason.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get delete_account_reason;

  /// No description provided for @account_deleted_successfully.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully.'**
  String get account_deleted_successfully;

  /// No description provided for @send_feedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get send_feedback;

  /// No description provided for @feedback_info_title.
  ///
  /// In en, this message translates to:
  /// **'Your feedback helps us improve'**
  String get feedback_info_title;

  /// No description provided for @feedback_info_description.
  ///
  /// In en, this message translates to:
  /// **'Share your feedback or suggestions so we can improve the app and make your experience better.'**
  String get feedback_info_description;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get name_hint;

  /// No description provided for @name_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get name_required;

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_number;

  /// No description provided for @phone_hint.
  ///
  /// In en, this message translates to:
  /// **'Phone number (optional)'**
  String get phone_hint;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @feedback_hint.
  ///
  /// In en, this message translates to:
  /// **'Write your feedback or suggestions here'**
  String get feedback_hint;

  /// No description provided for @feedback_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter a message'**
  String get feedback_required;

  /// No description provided for @feedback_submitted_successfully.
  ///
  /// In en, this message translates to:
  /// **'Feedback submitted successfully!'**
  String get feedback_submitted_successfully;

  /// No description provided for @user_feedbacks.
  ///
  /// In en, this message translates to:
  /// **'User Feedback'**
  String get user_feedbacks;

  /// No description provided for @no_feedbacks_yet.
  ///
  /// In en, this message translates to:
  /// **'No feedback yet'**
  String get no_feedbacks_yet;

  /// No description provided for @mark_as_read.
  ///
  /// In en, this message translates to:
  /// **'Mark as Read'**
  String get mark_as_read;

  /// No description provided for @mark_as_unread.
  ///
  /// In en, this message translates to:
  /// **'Mark as Unread'**
  String get mark_as_unread;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @delete_feedback.
  ///
  /// In en, this message translates to:
  /// **'Delete Feedback'**
  String get delete_feedback;

  /// No description provided for @delete_feedback_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this feedback? This action cannot be undone.'**
  String get delete_feedback_confirm;

  /// No description provided for @add_screenshot.
  ///
  /// In en, this message translates to:
  /// **'Add Screenshot'**
  String get add_screenshot;

  /// No description provided for @tap_to_select_image.
  ///
  /// In en, this message translates to:
  /// **'Tap to select an image'**
  String get tap_to_select_image;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @username_is_required.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get username_is_required;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @password_is_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get password_is_required;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgot_password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get login;

  /// No description provided for @sign_up.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get sign_up;

  /// No description provided for @or_text.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or_text;

  /// No description provided for @first_name.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get first_name;

  /// No description provided for @last_name.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get last_name;

  /// No description provided for @phone_required.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phone_required;

  /// No description provided for @invalid_phone_number.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get invalid_phone_number;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @city_is_required.
  ///
  /// In en, this message translates to:
  /// **'City is required'**
  String get city_is_required;

  /// No description provided for @confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password;

  /// No description provided for @confirm_password_is_required.
  ///
  /// In en, this message translates to:
  /// **'Confirm password is required'**
  String get confirm_password_is_required;

  /// No description provided for @passwords_do_not_match.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwords_do_not_match;

  /// No description provided for @account_created.
  ///
  /// In en, this message translates to:
  /// **'Account Created'**
  String get account_created;

  /// No description provided for @please_verify_email.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email address.'**
  String get please_verify_email;

  /// No description provided for @sign_up_failed.
  ///
  /// In en, this message translates to:
  /// **'Sign Up Failed'**
  String get sign_up_failed;

  /// No description provided for @start_your_solar_business.
  ///
  /// In en, this message translates to:
  /// **'Start your solar business'**
  String get start_your_solar_business;

  /// No description provided for @register_company_details.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details below to register your company. Our team will review your application before approval.'**
  String get register_company_details;

  /// No description provided for @company_name.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get company_name;

  /// No description provided for @company_name_is_required.
  ///
  /// In en, this message translates to:
  /// **'Company Name is required'**
  String get company_name_is_required;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @description_is_required.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get description_is_required;

  /// No description provided for @b2b.
  ///
  /// In en, this message translates to:
  /// **'B2B'**
  String get b2b;

  /// No description provided for @b2c.
  ///
  /// In en, this message translates to:
  /// **'B2C'**
  String get b2c;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @address_is_required.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get address_is_required;

  /// No description provided for @upload_logo.
  ///
  /// In en, this message translates to:
  /// **'Upload Logo'**
  String get upload_logo;

  /// No description provided for @business_phone.
  ///
  /// In en, this message translates to:
  /// **'Business Phone'**
  String get business_phone;

  /// No description provided for @submit_application.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get submit_application;

  /// No description provided for @company_registered_success.
  ///
  /// In en, this message translates to:
  /// **'Company registered successfully'**
  String get company_registered_success;

  /// No description provided for @company_updated_successfully.
  ///
  /// In en, this message translates to:
  /// **'Company updated successfully.'**
  String get company_updated_successfully;

  /// No description provided for @company_type.
  ///
  /// In en, this message translates to:
  /// **'Company Type'**
  String get company_type;

  /// No description provided for @company_type_required.
  ///
  /// In en, this message translates to:
  /// **'Company type is required'**
  String get company_type_required;

  /// No description provided for @edit_company.
  ///
  /// In en, this message translates to:
  /// **'Edit Company'**
  String get edit_company;

  /// No description provided for @company_profile.
  ///
  /// In en, this message translates to:
  /// **'Company Profile'**
  String get company_profile;

  /// No description provided for @company_profile_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your company profile up to date.'**
  String get company_profile_subtitle;

  /// No description provided for @company_activation_required_title.
  ///
  /// In en, this message translates to:
  /// **'Company activation required'**
  String get company_activation_required_title;

  /// No description provided for @company_activation_required_message.
  ///
  /// In en, this message translates to:
  /// **'This company is inactive or its subscription is not valid yet. Contact admin to activate the company and enable management actions.'**
  String get company_activation_required_message;

  /// No description provided for @company_activation_required_short.
  ///
  /// In en, this message translates to:
  /// **'Activation required'**
  String get company_activation_required_short;

  /// No description provided for @company_pending_activation_title.
  ///
  /// In en, this message translates to:
  /// **'Company activation is pending'**
  String get company_pending_activation_title;

  /// No description provided for @company_pending_activation_message.
  ///
  /// In en, this message translates to:
  /// **'Your company is still pending admin review. You can contact admin, and if the company has been waiting for more than 24 hours an activation reminder can be sent.'**
  String get company_pending_activation_message;

  /// No description provided for @company_send_activation_reminder.
  ///
  /// In en, this message translates to:
  /// **'Send activation reminder'**
  String get company_send_activation_reminder;

  /// No description provided for @company_activation_reminder_sent.
  ///
  /// In en, this message translates to:
  /// **'Activation reminder sent successfully.'**
  String get company_activation_reminder_sent;

  /// No description provided for @company_activation_reminder_sent_message.
  ///
  /// In en, this message translates to:
  /// **'An activation reminder was sent to admins. The next reminder will be available at {availableAt}.'**
  String company_activation_reminder_sent_message(Object availableAt);

  /// No description provided for @company_subscription_required_title.
  ///
  /// In en, this message translates to:
  /// **'Subscription required'**
  String get company_subscription_required_title;

  /// No description provided for @company_subscription_required_message.
  ///
  /// In en, this message translates to:
  /// **'Your company is active, but the subscription is not valid. Choose a plan below to submit a subscription request.'**
  String get company_subscription_required_message;

  /// No description provided for @company_subscription_available_plans.
  ///
  /// In en, this message translates to:
  /// **'Available subscription plans'**
  String get company_subscription_available_plans;

  /// No description provided for @company_subscription_plans_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load subscription plans.'**
  String get company_subscription_plans_error;

  /// No description provided for @company_subscription_plans_empty.
  ///
  /// In en, this message translates to:
  /// **'No subscription plans are available right now.'**
  String get company_subscription_plans_empty;

  /// No description provided for @company_subscription_plan_meta.
  ///
  /// In en, this message translates to:
  /// **'{days} days • {price}'**
  String company_subscription_plan_meta(Object days, Object price);

  /// No description provided for @company_subscription_request_cta.
  ///
  /// In en, this message translates to:
  /// **'Request this plan'**
  String get company_subscription_request_cta;

  /// No description provided for @company_subscription_notes.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get company_subscription_notes;

  /// No description provided for @company_subscription_image_optional.
  ///
  /// In en, this message translates to:
  /// **'Image (optional)'**
  String get company_subscription_image_optional;

  /// No description provided for @company_subscription_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit subscription request'**
  String get company_subscription_submit;

  /// No description provided for @company_subscription_request_submitted.
  ///
  /// In en, this message translates to:
  /// **'Subscription request submitted successfully.'**
  String get company_subscription_request_submitted;

  /// No description provided for @company_subscription_request_pending.
  ///
  /// In en, this message translates to:
  /// **'Subscription request pending review.'**
  String get company_subscription_request_pending;

  /// No description provided for @company_subscription_request_pending_message.
  ///
  /// In en, this message translates to:
  /// **'Your subscription request for {planName} is pending admin review.'**
  String company_subscription_request_pending_message(Object planName);

  /// No description provided for @company_call_admin.
  ///
  /// In en, this message translates to:
  /// **'Call admin'**
  String get company_call_admin;

  /// No description provided for @company_email_admin.
  ///
  /// In en, this message translates to:
  /// **'Email admin'**
  String get company_email_admin;

  /// No description provided for @company_chat_admin.
  ///
  /// In en, this message translates to:
  /// **'Chat with admin'**
  String get company_chat_admin;

  /// No description provided for @company_chat_admin_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Chat coming soon'**
  String get company_chat_admin_coming_soon;

  /// No description provided for @company_contact_admin_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the selected admin contact action.'**
  String get company_contact_admin_failed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @min_6_characters.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get min_6_characters;

  /// No description provided for @edit_profile_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile_title;

  /// No description provided for @edit_profile_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get edit_profile_tooltip;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @failed_to_pick_image.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String failed_to_pick_image(Object error);

  /// No description provided for @tap_to_change_avatar.
  ///
  /// In en, this message translates to:
  /// **'Tap to change avatar'**
  String get tap_to_change_avatar;

  /// No description provided for @security_question.
  ///
  /// In en, this message translates to:
  /// **'Security Question'**
  String get security_question;

  /// No description provided for @security_answer.
  ///
  /// In en, this message translates to:
  /// **'Security Answer'**
  String get security_answer;

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save_changes;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @my_posts.
  ///
  /// In en, this message translates to:
  /// **'My Posts'**
  String get my_posts;

  /// No description provided for @profile_id_short.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}...'**
  String profile_id_short(Object id);

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcome_back;

  /// No description provided for @choose_how_to_continue.
  ///
  /// In en, this message translates to:
  /// **'Choose how you want to continue'**
  String get choose_how_to_continue;

  /// No description provided for @solar_hub.
  ///
  /// In en, this message translates to:
  /// **'Solar Hub'**
  String get solar_hub;

  /// No description provided for @continue_as.
  ///
  /// In en, this message translates to:
  /// **'Continue as {name}'**
  String continue_as(Object name);

  /// No description provided for @platform_management.
  ///
  /// In en, this message translates to:
  /// **'Manage the platform'**
  String get platform_management;

  /// No description provided for @save_role_page_selection.
  ///
  /// In en, this message translates to:
  /// **'Remember this choice'**
  String get save_role_page_selection;

  /// No description provided for @use_the_power_of_the_sun.
  ///
  /// In en, this message translates to:
  /// **'Smarter solar starts here'**
  String get use_the_power_of_the_sun;

  /// No description provided for @default_user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get default_user;

  /// No description provided for @calculator_tools.
  ///
  /// In en, this message translates to:
  /// **'Calculator Tools'**
  String get calculator_tools;

  /// No description provided for @system_wizard.
  ///
  /// In en, this message translates to:
  /// **'System Calculator Wizard'**
  String get system_wizard;

  /// No description provided for @system_wizard_desc.
  ///
  /// In en, this message translates to:
  /// **'Answer a few questions to get a complete system recommendation'**
  String get system_wizard_desc;

  /// No description provided for @request_offer_wizard.
  ///
  /// In en, this message translates to:
  /// **'Request Custom Offer'**
  String get request_offer_wizard;

  /// No description provided for @request_offer_desc.
  ///
  /// In en, this message translates to:
  /// **'Submit your specific requirements to get offers from companies'**
  String get request_offer_desc;

  /// No description provided for @quick_tools.
  ///
  /// In en, this message translates to:
  /// **'Quick Tools'**
  String get quick_tools;

  /// No description provided for @panels_calc.
  ///
  /// In en, this message translates to:
  /// **'Panels'**
  String get panels_calc;

  /// No description provided for @inverter_calc.
  ///
  /// In en, this message translates to:
  /// **'Inverter'**
  String get inverter_calc;

  /// No description provided for @battery_calc.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get battery_calc;

  /// No description provided for @wires_calc.
  ///
  /// In en, this message translates to:
  /// **'Wires'**
  String get wires_calc;

  /// No description provided for @pump_calc.
  ///
  /// In en, this message translates to:
  /// **'Water Pump'**
  String get pump_calc;

  /// No description provided for @step_appliances.
  ///
  /// In en, this message translates to:
  /// **'Appliances'**
  String get step_appliances;

  /// No description provided for @step_usage.
  ///
  /// In en, this message translates to:
  /// **'Usage'**
  String get step_usage;

  /// No description provided for @step_results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get step_results;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculate;

  /// No description provided for @add_appliance.
  ///
  /// In en, this message translates to:
  /// **'Add Appliance'**
  String get add_appliance;

  /// No description provided for @autonomy_hours.
  ///
  /// In en, this message translates to:
  /// **'Autonomy Hours'**
  String get autonomy_hours;

  /// No description provided for @sun_hours.
  ///
  /// In en, this message translates to:
  /// **'Sun Peak Hours'**
  String get sun_hours;

  /// No description provided for @panel_wattage.
  ///
  /// In en, this message translates to:
  /// **'Panel Wattage'**
  String get panel_wattage;

  /// No description provided for @single_battery_voltage.
  ///
  /// In en, this message translates to:
  /// **'Single Battery Voltage'**
  String get single_battery_voltage;

  /// No description provided for @battery_type_hint.
  ///
  /// In en, this message translates to:
  /// **'Lithium usually 12.8V, 25.6V, 51.2V | Lead-Acid usually 12V'**
  String get battery_type_hint;

  /// No description provided for @system_voltage.
  ///
  /// In en, this message translates to:
  /// **'System Voltage'**
  String get system_voltage;

  /// No description provided for @recommended_system.
  ///
  /// In en, this message translates to:
  /// **'Recommended System'**
  String get recommended_system;

  /// No description provided for @panel_count.
  ///
  /// In en, this message translates to:
  /// **'Panel Count'**
  String get panel_count;

  /// No description provided for @inverter_size.
  ///
  /// In en, this message translates to:
  /// **'Inverter Size'**
  String get inverter_size;

  /// No description provided for @battery_bank.
  ///
  /// In en, this message translates to:
  /// **'Battery Bank'**
  String get battery_bank;

  /// No description provided for @request_this_system.
  ///
  /// In en, this message translates to:
  /// **'Request This System'**
  String get request_this_system;

  /// No description provided for @request_description.
  ///
  /// In en, this message translates to:
  /// **'Send this system configuration to local companies to get offers'**
  String get request_description;

  /// No description provided for @guide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get guide;

  /// No description provided for @dont_show_again.
  ///
  /// In en, this message translates to:
  /// **'Don\'t show this again'**
  String get dont_show_again;

  /// No description provided for @capacity_kw.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity_kw;

  /// No description provided for @voltage_type.
  ///
  /// In en, this message translates to:
  /// **'Voltage Type'**
  String get voltage_type;

  /// No description provided for @phase.
  ///
  /// In en, this message translates to:
  /// **'Phase'**
  String get phase;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @battery_voltage.
  ///
  /// In en, this message translates to:
  /// **'Battery Voltage'**
  String get battery_voltage;

  /// No description provided for @battery_amp.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get battery_amp;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @notes_details.
  ///
  /// In en, this message translates to:
  /// **'Notes & Details'**
  String get notes_details;

  /// No description provided for @submit_request.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submit_request;

  /// No description provided for @notes_optional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notes_optional;

  /// No description provided for @notes_brand.
  ///
  /// In en, this message translates to:
  /// **'Notes (Brand, specific type...)'**
  String get notes_brand;

  /// No description provided for @three_phase.
  ///
  /// In en, this message translates to:
  /// **'Three Phase'**
  String get three_phase;

  /// No description provided for @voltage_110.
  ///
  /// In en, this message translates to:
  /// **'110 V'**
  String get voltage_110;

  /// No description provided for @voltage_230.
  ///
  /// In en, this message translates to:
  /// **'230 V'**
  String get voltage_230;

  /// No description provided for @voltage_380_three_phase.
  ///
  /// In en, this message translates to:
  /// **'380 V (Three-phase)'**
  String get voltage_380_three_phase;

  /// No description provided for @confirm_submit.
  ///
  /// In en, this message translates to:
  /// **'Confirm Submit'**
  String get confirm_submit;

  /// No description provided for @create_new_system.
  ///
  /// In en, this message translates to:
  /// **'Create New System'**
  String get create_new_system;

  /// No description provided for @enter_system_name.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for your new system:'**
  String get enter_system_name;

  /// No description provided for @back_to_list.
  ///
  /// In en, this message translates to:
  /// **'Back to List'**
  String get back_to_list;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @error_enter_system_name.
  ///
  /// In en, this message translates to:
  /// **'Required: Please enter a system name'**
  String get error_enter_system_name;

  /// No description provided for @error_select_system.
  ///
  /// In en, this message translates to:
  /// **'Required: Please select a system'**
  String get error_select_system;

  /// No description provided for @error_no_components.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one component (Panel, Inverter, or Battery)'**
  String get error_no_components;

  /// No description provided for @appliance_name.
  ///
  /// In en, this message translates to:
  /// **'Appliance Name'**
  String get appliance_name;

  /// No description provided for @power_watts.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get power_watts;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @hours_per_day.
  ///
  /// In en, this message translates to:
  /// **'Hours/Day'**
  String get hours_per_day;

  /// No description provided for @no_company_found.
  ///
  /// In en, this message translates to:
  /// **'No Company Found'**
  String get no_company_found;

  /// No description provided for @not_linked_company.
  ///
  /// In en, this message translates to:
  /// **'You are not linked to any company yet.'**
  String get not_linked_company;

  /// No description provided for @verification_pending.
  ///
  /// In en, this message translates to:
  /// **'Verification Pending'**
  String get verification_pending;

  /// No description provided for @verification_pending_msg.
  ///
  /// In en, this message translates to:
  /// **'Your company registration is under review. Please check back later.'**
  String get verification_pending_msg;

  /// No description provided for @go_back.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get go_back;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @stock_value.
  ///
  /// In en, this message translates to:
  /// **'Stock Value'**
  String get stock_value;

  /// No description provided for @pending_orders.
  ///
  /// In en, this message translates to:
  /// **'Pending Orders'**
  String get pending_orders;

  /// No description provided for @open_requests.
  ///
  /// In en, this message translates to:
  /// **'Open Requests'**
  String get open_requests;

  /// No description provided for @low_stock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get low_stock;

  /// No description provided for @manage_business.
  ///
  /// In en, this message translates to:
  /// **'Manage Business'**
  String get manage_business;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @pos.
  ///
  /// In en, this message translates to:
  /// **'Point of Sale'**
  String get pos;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @accounting.
  ///
  /// In en, this message translates to:
  /// **'Accounting'**
  String get accounting;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @members_add_member.
  ///
  /// In en, this message translates to:
  /// **'Add member'**
  String get members_add_member;

  /// No description provided for @members_team_overview.
  ///
  /// In en, this message translates to:
  /// **'Team overview'**
  String get members_team_overview;

  /// No description provided for @members_count_summary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No members yet} =1{1 member in this company} other{{count} members in this company}}'**
  String members_count_summary(int count);

  /// No description provided for @members_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No members yet'**
  String get members_empty_title;

  /// No description provided for @members_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Company members will appear here once they join.'**
  String get members_empty_subtitle;

  /// No description provided for @members_company_required.
  ///
  /// In en, this message translates to:
  /// **'No company is selected for this account.'**
  String get members_company_required;

  /// No description provided for @members_add_description.
  ///
  /// In en, this message translates to:
  /// **'Invite an existing user first. If they do not have an account yet, you can create one from the same flow.'**
  String get members_add_description;

  /// No description provided for @members_invite_description.
  ///
  /// In en, this message translates to:
  /// **'Invite an existing user by email and assign their company role.'**
  String get members_invite_description;

  /// No description provided for @members_create_description.
  ///
  /// In en, this message translates to:
  /// **'Create a new account and add it directly to this company.'**
  String get members_create_description;

  /// No description provided for @members_create_title.
  ///
  /// In en, this message translates to:
  /// **'Create new member'**
  String get members_create_title;

  /// No description provided for @members_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get members_email;

  /// No description provided for @members_username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get members_username;

  /// No description provided for @members_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get members_password;

  /// No description provided for @members_first_name.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get members_first_name;

  /// No description provided for @members_last_name.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get members_last_name;

  /// No description provided for @members_role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get members_role;

  /// No description provided for @members_invite_member.
  ///
  /// In en, this message translates to:
  /// **'Invite member'**
  String get members_invite_member;

  /// No description provided for @members_create_member.
  ///
  /// In en, this message translates to:
  /// **'Create member'**
  String get members_create_member;

  /// No description provided for @members_back_to_invite.
  ///
  /// In en, this message translates to:
  /// **'Back to invite'**
  String get members_back_to_invite;

  /// No description provided for @members_remove_member.
  ///
  /// In en, this message translates to:
  /// **'Remove member'**
  String get members_remove_member;

  /// No description provided for @members_remove_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from this company?'**
  String members_remove_confirmation(Object name);

  /// No description provided for @members_remove_success.
  ///
  /// In en, this message translates to:
  /// **'Member removed successfully.'**
  String get members_remove_success;

  /// No description provided for @members_remove_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not remove the member.'**
  String get members_remove_failed;

  /// No description provided for @members_invite_success.
  ///
  /// In en, this message translates to:
  /// **'Member invited successfully.'**
  String get members_invite_success;

  /// No description provided for @members_invite_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not invite this member.'**
  String get members_invite_failed;

  /// No description provided for @members_create_success.
  ///
  /// In en, this message translates to:
  /// **'Member created and added successfully.'**
  String get members_create_success;

  /// No description provided for @members_create_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not create this member.'**
  String get members_create_failed;

  /// No description provided for @members_requires_registration.
  ///
  /// In en, this message translates to:
  /// **'This email does not have an account yet. Complete the create-member form.'**
  String get members_requires_registration;

  /// No description provided for @members_email_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required.'**
  String get members_email_required;

  /// No description provided for @members_email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get members_email_invalid;

  /// No description provided for @members_username_required.
  ///
  /// In en, this message translates to:
  /// **'Username is required.'**
  String get members_username_required;

  /// No description provided for @members_password_required.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get members_password_required;

  /// No description provided for @members_password_too_short.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get members_password_too_short;

  /// No description provided for @members_first_name_required.
  ///
  /// In en, this message translates to:
  /// **'First name is required.'**
  String get members_first_name_required;

  /// No description provided for @members_last_name_required.
  ///
  /// In en, this message translates to:
  /// **'Last name is required.'**
  String get members_last_name_required;

  /// No description provided for @members_joined_on.
  ///
  /// In en, this message translates to:
  /// **'Joined on {date}'**
  String members_joined_on(Object date);

  /// No description provided for @members_role_admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get members_role_admin;

  /// No description provided for @members_role_manager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get members_role_manager;

  /// No description provided for @members_role_staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get members_role_staff;

  /// No description provided for @members_role_accountant.
  ///
  /// In en, this message translates to:
  /// **'Accountant'**
  String get members_role_accountant;

  /// No description provided for @members_role_delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get members_role_delivery;

  /// No description provided for @members_role_installer.
  ///
  /// In en, this message translates to:
  /// **'Installer'**
  String get members_role_installer;

  /// No description provided for @members_role_inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get members_role_inventory;

  /// No description provided for @members_role_sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get members_role_sales;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @suppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers;

  /// No description provided for @my_purchases.
  ///
  /// In en, this message translates to:
  /// **'My Purchases'**
  String get my_purchases;

  /// No description provided for @tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get tools;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @services_explorer_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse trusted solar companies by service type, then open the companies that match what you need.'**
  String get services_explorer_subtitle;

  /// No description provided for @services_choose_category.
  ///
  /// In en, this message translates to:
  /// **'Choose a service category'**
  String get services_choose_category;

  /// No description provided for @services_no_categories.
  ///
  /// In en, this message translates to:
  /// **'No service categories are available yet.'**
  String get services_no_categories;

  /// No description provided for @services_explore_companies.
  ///
  /// In en, this message translates to:
  /// **'Explore companies'**
  String get services_explore_companies;

  /// No description provided for @services_companies_found.
  ///
  /// In en, this message translates to:
  /// **'{count} companies found'**
  String services_companies_found(Object count);

  /// No description provided for @services_companies_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Find public companies that match this service type. Change city or search to narrow the results.'**
  String get services_companies_subtitle;

  /// No description provided for @services_all_cities.
  ///
  /// In en, this message translates to:
  /// **'All cities'**
  String get services_all_cities;

  /// No description provided for @services_search_companies.
  ///
  /// In en, this message translates to:
  /// **'Search companies'**
  String get services_search_companies;

  /// No description provided for @services_no_companies_found.
  ///
  /// In en, this message translates to:
  /// **'No companies matched this service type with the current filters.'**
  String get services_no_companies_found;

  /// No description provided for @services_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get services_retry;

  /// No description provided for @services_public_badge.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get services_public_badge;

  /// No description provided for @services_contacts_count.
  ///
  /// In en, this message translates to:
  /// **'{count} contacts'**
  String services_contacts_count(Object count);

  /// No description provided for @services_services_count.
  ///
  /// In en, this message translates to:
  /// **'{count} services'**
  String services_services_count(Object count);

  /// No description provided for @services_company_details.
  ///
  /// In en, this message translates to:
  /// **'Company details'**
  String get services_company_details;

  /// No description provided for @services_company_info.
  ///
  /// In en, this message translates to:
  /// **'Company info'**
  String get services_company_info;

  /// No description provided for @services_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get services_address;

  /// No description provided for @services_no_address.
  ///
  /// In en, this message translates to:
  /// **'No address'**
  String get services_no_address;

  /// No description provided for @services_city_label.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get services_city_label;

  /// No description provided for @services_not_specified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get services_not_specified;

  /// No description provided for @services_type_label.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get services_type_label;

  /// No description provided for @services_phone_label.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get services_phone_label;

  /// No description provided for @services_no_phone.
  ///
  /// In en, this message translates to:
  /// **'No phone number'**
  String get services_no_phone;

  /// No description provided for @services_section_services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services_section_services;

  /// No description provided for @services_no_public_services.
  ///
  /// In en, this message translates to:
  /// **'No public services listed yet.'**
  String get services_no_public_services;

  /// No description provided for @services_price_on_request.
  ///
  /// In en, this message translates to:
  /// **'Price on request'**
  String get services_price_on_request;

  /// No description provided for @services_contacts_title.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get services_contacts_title;

  /// No description provided for @services_no_contacts.
  ///
  /// In en, this message translates to:
  /// **'No contacts available.'**
  String get services_no_contacts;

  /// No description provided for @services_delivery_options.
  ///
  /// In en, this message translates to:
  /// **'Delivery options'**
  String get services_delivery_options;

  /// No description provided for @services_no_delivery_options.
  ///
  /// In en, this message translates to:
  /// **'No delivery options available.'**
  String get services_no_delivery_options;

  /// No description provided for @services_flexible_delivery.
  ///
  /// In en, this message translates to:
  /// **'Flexible'**
  String get services_flexible_delivery;

  /// No description provided for @services_estimated_days.
  ///
  /// In en, this message translates to:
  /// **'Estimated: {min} - {max} days'**
  String services_estimated_days(Object min, Object max);

  /// No description provided for @contacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts;

  /// No description provided for @company_contacts_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage contact people for your company.'**
  String get company_contacts_subtitle;

  /// No description provided for @company_contacts_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading contacts...'**
  String get company_contacts_loading;

  /// No description provided for @company_contacts_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No contacts yet'**
  String get company_contacts_empty_title;

  /// No description provided for @company_contacts_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first company contact.'**
  String get company_contacts_empty_subtitle;

  /// No description provided for @company_contacts_add.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get company_contacts_add;

  /// No description provided for @company_contacts_save.
  ///
  /// In en, this message translates to:
  /// **'Save contact'**
  String get company_contacts_save;

  /// No description provided for @company_contacts_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get company_contacts_name;

  /// No description provided for @company_contacts_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get company_contacts_email;

  /// No description provided for @company_contacts_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get company_contacts_phone;

  /// No description provided for @company_contacts_notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get company_contacts_notes;

  /// No description provided for @company_contacts_name_required.
  ///
  /// In en, this message translates to:
  /// **'Contact name is required'**
  String get company_contacts_name_required;

  /// No description provided for @company_contacts_email_required.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get company_contacts_email_required;

  /// No description provided for @company_contacts_email_invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get company_contacts_email_invalid;

  /// No description provided for @company_contacts_phone_required.
  ///
  /// In en, this message translates to:
  /// **'Phone is required'**
  String get company_contacts_phone_required;

  /// No description provided for @company_contacts_deleted.
  ///
  /// In en, this message translates to:
  /// **'Contact deleted successfully.'**
  String get company_contacts_deleted;

  /// No description provided for @company_contacts_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete contact'**
  String get company_contacts_delete_title;

  /// No description provided for @company_contacts_delete_message.
  ///
  /// In en, this message translates to:
  /// **'Delete {name} from contacts?'**
  String company_contacts_delete_message(Object name);

  /// No description provided for @company_contacts_no_company.
  ///
  /// In en, this message translates to:
  /// **'A company account is required to manage contacts.'**
  String get company_contacts_no_company;

  /// No description provided for @company_public_services.
  ///
  /// In en, this message translates to:
  /// **'Public Services'**
  String get company_public_services;

  /// No description provided for @company_public_services_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Show the services your company offers publicly.'**
  String get company_public_services_subtitle;

  /// No description provided for @company_public_services_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading public services...'**
  String get company_public_services_loading;

  /// No description provided for @company_public_services_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No public services yet'**
  String get company_public_services_empty_title;

  /// No description provided for @company_public_services_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create the first public service for your company.'**
  String get company_public_services_empty_subtitle;

  /// No description provided for @company_public_services_add.
  ///
  /// In en, this message translates to:
  /// **'Add service'**
  String get company_public_services_add;

  /// No description provided for @company_public_services_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit service'**
  String get company_public_services_edit;

  /// No description provided for @company_public_services_save.
  ///
  /// In en, this message translates to:
  /// **'Save service'**
  String get company_public_services_save;

  /// No description provided for @company_public_services_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get company_public_services_title;

  /// No description provided for @company_public_services_title_required.
  ///
  /// In en, this message translates to:
  /// **'Service title is required'**
  String get company_public_services_title_required;

  /// No description provided for @company_public_services_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get company_public_services_price;

  /// No description provided for @company_public_services_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get company_public_services_description;

  /// No description provided for @company_public_services_deleted.
  ///
  /// In en, this message translates to:
  /// **'Public service deleted successfully.'**
  String get company_public_services_deleted;

  /// No description provided for @company_public_services_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete public service'**
  String get company_public_services_delete_title;

  /// No description provided for @company_public_services_delete_message.
  ///
  /// In en, this message translates to:
  /// **'Delete {name} from public services?'**
  String company_public_services_delete_message(Object name);

  /// No description provided for @company_public_services_no_company.
  ///
  /// In en, this message translates to:
  /// **'A company account is required to manage public services.'**
  String get company_public_services_no_company;

  /// No description provided for @company_categories_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your company with custom categories.'**
  String get company_categories_subtitle;

  /// No description provided for @company_categories_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading categories...'**
  String get company_categories_loading;

  /// No description provided for @company_categories_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get company_categories_empty_title;

  /// No description provided for @company_categories_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create the first category for your company.'**
  String get company_categories_empty_subtitle;

  /// No description provided for @company_categories_add.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get company_categories_add;

  /// No description provided for @company_categories_save.
  ///
  /// In en, this message translates to:
  /// **'Save category'**
  String get company_categories_save;

  /// No description provided for @company_categories_name.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get company_categories_name;

  /// No description provided for @company_categories_name_required.
  ///
  /// In en, this message translates to:
  /// **'Category name is required'**
  String get company_categories_name_required;

  /// No description provided for @company_categories_deleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted successfully.'**
  String get company_categories_deleted;

  /// No description provided for @company_categories_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get company_categories_delete_title;

  /// No description provided for @company_categories_delete_message.
  ///
  /// In en, this message translates to:
  /// **'Delete {name} from categories?'**
  String company_categories_delete_message(Object name);

  /// No description provided for @company_categories_no_company.
  ///
  /// In en, this message translates to:
  /// **'A company account is required to manage categories.'**
  String get company_categories_no_company;

  /// No description provided for @status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get status_active;

  /// No description provided for @status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get status_pending;

  /// No description provided for @status_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get status_rejected;

  /// No description provided for @status_suspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get status_suspended;

  /// No description provided for @status_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get status_cancelled;

  /// No description provided for @status_accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get status_accepted;

  /// No description provided for @status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get status_completed;

  /// No description provided for @status_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get status_unavailable;

  /// No description provided for @request_status_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get request_status_open;

  /// No description provided for @request_status_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get request_status_closed;

  /// No description provided for @request_status_fulfilled.
  ///
  /// In en, this message translates to:
  /// **'Fulfilled'**
  String get request_status_fulfilled;

  /// No description provided for @battery_type_gel.
  ///
  /// In en, this message translates to:
  /// **'Gel'**
  String get battery_type_gel;

  /// No description provided for @battery_type_tubular.
  ///
  /// In en, this message translates to:
  /// **'Tubular'**
  String get battery_type_tubular;

  /// No description provided for @battery_type_lithium.
  ///
  /// In en, this message translates to:
  /// **'Lithium'**
  String get battery_type_lithium;

  /// No description provided for @inverter_type_off_grid.
  ///
  /// In en, this message translates to:
  /// **'Off Grid'**
  String get inverter_type_off_grid;

  /// No description provided for @inverter_type_on_grid.
  ///
  /// In en, this message translates to:
  /// **'On Grid'**
  String get inverter_type_on_grid;

  /// No description provided for @inverter_type_hybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get inverter_type_hybrid;

  /// No description provided for @offers_catalog.
  ///
  /// In en, this message translates to:
  /// **'Offers Catalog'**
  String get offers_catalog;

  /// No description provided for @manage_extra_fees.
  ///
  /// In en, this message translates to:
  /// **'Manage Extra Fees'**
  String get manage_extra_fees;

  /// No description provided for @manage_extra_fees_desc.
  ///
  /// In en, this message translates to:
  /// **'Use this list for installation fees, delivery, mounting, wiring, or other extra services you add to offers.'**
  String get manage_extra_fees_desc;

  /// No description provided for @no_involves_yet.
  ///
  /// In en, this message translates to:
  /// **'No involves yet'**
  String get no_involves_yet;

  /// No description provided for @no_involves_yet_desc.
  ///
  /// In en, this message translates to:
  /// **'Create your first extra cost item to reuse it in offer replies.'**
  String get no_involves_yet_desc;

  /// No description provided for @create_item.
  ///
  /// In en, this message translates to:
  /// **'Create item'**
  String get create_item;

  /// No description provided for @active_in_offers.
  ///
  /// In en, this message translates to:
  /// **'Active in offers'**
  String get active_in_offers;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @create_involve.
  ///
  /// In en, this message translates to:
  /// **'Create involve'**
  String get create_involve;

  /// No description provided for @edit_involve.
  ///
  /// In en, this message translates to:
  /// **'Edit involve'**
  String get edit_involve;

  /// No description provided for @involve_examples.
  ///
  /// In en, this message translates to:
  /// **'Examples: installation fee, delivery, mounting structure.'**
  String get involve_examples;

  /// No description provided for @delete_item.
  ///
  /// In en, this message translates to:
  /// **'Delete item?'**
  String get delete_item;

  /// No description provided for @delete_item_desc.
  ///
  /// In en, this message translates to:
  /// **'This item will be removed from your involves catalog.'**
  String get delete_item_desc;

  /// No description provided for @offers_marketplace.
  ///
  /// In en, this message translates to:
  /// **'Solar Marketplace'**
  String get offers_marketplace;

  /// No description provided for @available_requests.
  ///
  /// In en, this message translates to:
  /// **'Available Requests'**
  String get available_requests;

  /// No description provided for @my_bids.
  ///
  /// In en, this message translates to:
  /// **'My Bids'**
  String get my_bids;

  /// No description provided for @no_requests_found.
  ///
  /// In en, this message translates to:
  /// **'No requests found'**
  String get no_requests_found;

  /// No description provided for @no_offers_found.
  ///
  /// In en, this message translates to:
  /// **'No offers found'**
  String get no_offers_found;

  /// No description provided for @new_projects_will_appear_here.
  ///
  /// In en, this message translates to:
  /// **'New solar projects in your area will appear here.'**
  String get new_projects_will_appear_here;

  /// No description provided for @browse_requests_to_start_bidding.
  ///
  /// In en, this message translates to:
  /// **'Browse the requests tab to start bidding on projects.'**
  String get browse_requests_to_start_bidding;

  /// No description provided for @admin_marketplace_oversight.
  ///
  /// In en, this message translates to:
  /// **'Admin: Marketplace Oversight'**
  String get admin_marketplace_oversight;

  /// No description provided for @all_requests.
  ///
  /// In en, this message translates to:
  /// **'All Requests'**
  String get all_requests;

  /// No description provided for @all_offers.
  ///
  /// In en, this message translates to:
  /// **'All Offers'**
  String get all_offers;

  /// No description provided for @my_solar_project_inquiries.
  ///
  /// In en, this message translates to:
  /// **'My Solar Project Inquiries'**
  String get my_solar_project_inquiries;

  /// No description provided for @add_new_request.
  ///
  /// In en, this message translates to:
  /// **'Add New Request'**
  String get add_new_request;

  /// No description provided for @received_offers_count.
  ///
  /// In en, this message translates to:
  /// **'Received Offers ({count})'**
  String received_offers_count(Object count);

  /// No description provided for @no_offers_received_yet.
  ///
  /// In en, this message translates to:
  /// **'No offers received yet.'**
  String get no_offers_received_yet;

  /// No description provided for @no_requests_posted.
  ///
  /// In en, this message translates to:
  /// **'No requests posted'**
  String get no_requests_posted;

  /// No description provided for @post_first_solar_request.
  ///
  /// In en, this message translates to:
  /// **'Ready to save on energy? Post your first solar request and get bids from solar companies.'**
  String get post_first_solar_request;

  /// No description provided for @create_solar_request.
  ///
  /// In en, this message translates to:
  /// **'Create Solar Request'**
  String get create_solar_request;

  /// No description provided for @location_preferences.
  ///
  /// In en, this message translates to:
  /// **'Location Preferences'**
  String get location_preferences;

  /// No description provided for @broadcast_to_all_cities.
  ///
  /// In en, this message translates to:
  /// **'Broadcast to All Cities'**
  String get broadcast_to_all_cities;

  /// No description provided for @broadcast_to_all_cities_desc.
  ///
  /// In en, this message translates to:
  /// **'Enable to reach companies nationwide'**
  String get broadcast_to_all_cities_desc;

  /// No description provided for @solar_panel_needs.
  ///
  /// In en, this message translates to:
  /// **'Solar Panel Needs'**
  String get solar_panel_needs;

  /// No description provided for @expected_power_per_unit.
  ///
  /// In en, this message translates to:
  /// **'Expected Power/Unit (W)'**
  String get expected_power_per_unit;

  /// No description provided for @quantity_needed.
  ///
  /// In en, this message translates to:
  /// **'Quantity Needed'**
  String get quantity_needed;

  /// No description provided for @estimated_pv_power_needed.
  ///
  /// In en, this message translates to:
  /// **'Estimated PV Power Needed'**
  String get estimated_pv_power_needed;

  /// No description provided for @storage_requirements.
  ///
  /// In en, this message translates to:
  /// **'Storage Requirements'**
  String get storage_requirements;

  /// No description provided for @preferred_battery_type.
  ///
  /// In en, this message translates to:
  /// **'Preferred Battery Type'**
  String get preferred_battery_type;

  /// No description provided for @battery_size_wh.
  ///
  /// In en, this message translates to:
  /// **'Battery Size (Wh)'**
  String get battery_size_wh;

  /// No description provided for @total_energy_capacity_needed.
  ///
  /// In en, this message translates to:
  /// **'Total Energy Capacity Needed'**
  String get total_energy_capacity_needed;

  /// No description provided for @inverter_configuration.
  ///
  /// In en, this message translates to:
  /// **'Inverter Configuration'**
  String get inverter_configuration;

  /// No description provided for @desired_inverter_type.
  ///
  /// In en, this message translates to:
  /// **'Desired Inverter Type'**
  String get desired_inverter_type;

  /// No description provided for @total_inverter_power_peak.
  ///
  /// In en, this message translates to:
  /// **'Total Inverter Power Peak'**
  String get total_inverter_power_peak;

  /// No description provided for @additional_specifications.
  ///
  /// In en, this message translates to:
  /// **'Additional Specifications'**
  String get additional_specifications;

  /// No description provided for @project_description_notes.
  ///
  /// In en, this message translates to:
  /// **'Project Description / Notes'**
  String get project_description_notes;

  /// No description provided for @required_field.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required_field;

  /// No description provided for @post_solar_request.
  ///
  /// In en, this message translates to:
  /// **'Post Solar Request'**
  String get post_solar_request;

  /// No description provided for @new_offer_proposal.
  ///
  /// In en, this message translates to:
  /// **'New Offer Proposal'**
  String get new_offer_proposal;

  /// No description provided for @financial_information.
  ///
  /// In en, this message translates to:
  /// **'Financial Information'**
  String get financial_information;

  /// No description provided for @solar_panels.
  ///
  /// In en, this message translates to:
  /// **'Solar Panels'**
  String get solar_panels;

  /// No description provided for @power_per_unit.
  ///
  /// In en, this message translates to:
  /// **'Power/Unit (W)'**
  String get power_per_unit;

  /// No description provided for @total_energy_capacity.
  ///
  /// In en, this message translates to:
  /// **'Total Energy Capacity'**
  String get total_energy_capacity;

  /// No description provided for @battery_type_label.
  ///
  /// In en, this message translates to:
  /// **'Battery Type'**
  String get battery_type_label;

  /// No description provided for @inverter_type_label.
  ///
  /// In en, this message translates to:
  /// **'Inverter Type'**
  String get inverter_type_label;

  /// No description provided for @storage_batteries.
  ///
  /// In en, this message translates to:
  /// **'Storage (Batteries)'**
  String get storage_batteries;

  /// No description provided for @additional_notes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additional_notes;

  /// No description provided for @notes_for_user.
  ///
  /// In en, this message translates to:
  /// **'Notes for the User'**
  String get notes_for_user;

  /// No description provided for @enter_quotation_price.
  ///
  /// In en, this message translates to:
  /// **'Enter quotation price'**
  String get enter_quotation_price;

  /// No description provided for @price_required.
  ///
  /// In en, this message translates to:
  /// **'Price is required'**
  String get price_required;

  /// No description provided for @submit_quotation.
  ///
  /// In en, this message translates to:
  /// **'Submit Quotation'**
  String get submit_quotation;

  /// No description provided for @offer_details.
  ///
  /// In en, this message translates to:
  /// **'Offer Details'**
  String get offer_details;

  /// No description provided for @offering_price.
  ///
  /// In en, this message translates to:
  /// **'Offering Price'**
  String get offering_price;

  /// No description provided for @technical_specifications.
  ///
  /// In en, this message translates to:
  /// **'Technical Specifications'**
  String get technical_specifications;

  /// No description provided for @included_services_items.
  ///
  /// In en, this message translates to:
  /// **'Included Services & Items'**
  String get included_services_items;

  /// No description provided for @notes_from_provider.
  ///
  /// In en, this message translates to:
  /// **'Notes from Provider'**
  String get notes_from_provider;

  /// No description provided for @submitted_on_date.
  ///
  /// In en, this message translates to:
  /// **'Submitted on {date}'**
  String submitted_on_date(Object date);

  /// No description provided for @quotation.
  ///
  /// In en, this message translates to:
  /// **'Quotation'**
  String get quotation;

  /// No description provided for @panels.
  ///
  /// In en, this message translates to:
  /// **'Panels'**
  String get panels;

  /// No description provided for @battery_storage.
  ///
  /// In en, this message translates to:
  /// **'Battery & Storage'**
  String get battery_storage;

  /// No description provided for @total_project_quote.
  ///
  /// In en, this message translates to:
  /// **'Total Project Quote'**
  String get total_project_quote;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @accept_offer.
  ///
  /// In en, this message translates to:
  /// **'Accept Offer'**
  String get accept_offer;

  /// No description provided for @reject_offer.
  ///
  /// In en, this message translates to:
  /// **'Reject Offer'**
  String get reject_offer;

  /// No description provided for @solar_request_details.
  ///
  /// In en, this message translates to:
  /// **'Solar Request Details'**
  String get solar_request_details;

  /// No description provided for @user_needs.
  ///
  /// In en, this message translates to:
  /// **'User Needs'**
  String get user_needs;

  /// No description provided for @technical_notes.
  ///
  /// In en, this message translates to:
  /// **'Technical Notes'**
  String get technical_notes;

  /// No description provided for @send_offer_for_request.
  ///
  /// In en, this message translates to:
  /// **'Send Offer for this Request'**
  String get send_offer_for_request;

  /// No description provided for @panels_power.
  ///
  /// In en, this message translates to:
  /// **'Panels Power'**
  String get panels_power;

  /// No description provided for @battery_power.
  ///
  /// In en, this message translates to:
  /// **'Battery Power'**
  String get battery_power;

  /// No description provided for @battery_type_full.
  ///
  /// In en, this message translates to:
  /// **'Battery Type'**
  String get battery_type_full;

  /// No description provided for @pv_power.
  ///
  /// In en, this message translates to:
  /// **'PV Power'**
  String get pv_power;

  /// No description provided for @battery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get battery;

  /// No description provided for @city_label.
  ///
  /// In en, this message translates to:
  /// **'City: {city}'**
  String city_label(Object city);

  /// No description provided for @company_dashboard_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your solar operations efficiently'**
  String get company_dashboard_subtitle;

  /// No description provided for @error_loading_data.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get error_loading_data;

  /// No description provided for @section_label.
  ///
  /// In en, this message translates to:
  /// **'Section: {name}'**
  String section_label(Object name);

  /// No description provided for @quick_stats.
  ///
  /// In en, this message translates to:
  /// **'Quick Stats'**
  String get quick_stats;

  /// No description provided for @ready_to_scale_business.
  ///
  /// In en, this message translates to:
  /// **'Ready to scale your business?'**
  String get ready_to_scale_business;

  /// No description provided for @monitor_growth_subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Monitor your growth and subscriptions here.'**
  String get monitor_growth_subscriptions;

  /// No description provided for @solar_solutions_provider.
  ///
  /// In en, this message translates to:
  /// **'Solar Solutions Provider'**
  String get solar_solutions_provider;

  /// No description provided for @standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @admin_user.
  ///
  /// In en, this message translates to:
  /// **'Admin User'**
  String get admin_user;

  /// No description provided for @super_admin.
  ///
  /// In en, this message translates to:
  /// **'Super Admin'**
  String get super_admin;

  /// No description provided for @ready_to_scale_title.
  ///
  /// In en, this message translates to:
  /// **'Ready to Scale?'**
  String get ready_to_scale_title;

  /// No description provided for @service_not_requested.
  ///
  /// In en, this message translates to:
  /// **'You have not requested access to {service} yet.'**
  String service_not_requested(Object service);

  /// No description provided for @service_unlock_description.
  ///
  /// In en, this message translates to:
  /// **'Unlock this service to enhance your solar business and automate your workflow.'**
  String get service_unlock_description;

  /// No description provided for @access_requested_successfully.
  ///
  /// In en, this message translates to:
  /// **'Access requested successfully!'**
  String get access_requested_successfully;

  /// No description provided for @request_access_now.
  ///
  /// In en, this message translates to:
  /// **'Request Access Now'**
  String get request_access_now;

  /// No description provided for @awaiting_approval.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Approval'**
  String get awaiting_approval;

  /// No description provided for @service_under_review.
  ///
  /// In en, this message translates to:
  /// **'Your application for {service} is currently under review.'**
  String service_under_review(Object service);

  /// No description provided for @service_pending_help.
  ///
  /// In en, this message translates to:
  /// **'Our team usually takes 24-48 hours to approve new services. Please wait or contact support for help.'**
  String get service_pending_help;

  /// No description provided for @contact_support.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contact_support;

  /// No description provided for @request_denied.
  ///
  /// In en, this message translates to:
  /// **'Request Denied'**
  String get request_denied;

  /// No description provided for @service_request_rejected.
  ///
  /// In en, this message translates to:
  /// **'Your request for {service} has been rejected.'**
  String service_request_rejected(Object service);

  /// No description provided for @service_rejected_help.
  ///
  /// In en, this message translates to:
  /// **'This might be due to missing information or eligibility. Please reach out to our team to appeal.'**
  String get service_rejected_help;

  /// No description provided for @appeal_decision.
  ///
  /// In en, this message translates to:
  /// **'Appeal Decision'**
  String get appeal_decision;

  /// No description provided for @access_limited.
  ///
  /// In en, this message translates to:
  /// **'Access Limited'**
  String get access_limited;

  /// No description provided for @service_suspended_or_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Your {service} service is currently suspended or cancelled.'**
  String service_suspended_or_cancelled(Object service);

  /// No description provided for @service_accounts_help.
  ///
  /// In en, this message translates to:
  /// **'Please check your subscription status or contact our customer team to resolve this issue.'**
  String get service_accounts_help;

  /// No description provided for @contact_accounts.
  ///
  /// In en, this message translates to:
  /// **'Contact Accounts'**
  String get contact_accounts;

  /// No description provided for @service_maintenance.
  ///
  /// In en, this message translates to:
  /// **'Service Maintenance'**
  String get service_maintenance;

  /// No description provided for @service_being_updated.
  ///
  /// In en, this message translates to:
  /// **'{service} is currently being updated.'**
  String service_being_updated(Object service);

  /// No description provided for @service_maintenance_help.
  ///
  /// In en, this message translates to:
  /// **'We are adding new features to improve your experience. Check back shortly!'**
  String get service_maintenance_help;

  /// No description provided for @back_to_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to Dashboard'**
  String get back_to_dashboard;

  /// No description provided for @maybe_later.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybe_later;

  /// No description provided for @email_support.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get email_support;

  /// No description provided for @chat_on_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'Chat on WhatsApp'**
  String get chat_on_whatsapp;

  /// No description provided for @systems.
  ///
  /// In en, this message translates to:
  /// **'Systems'**
  String get systems;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @switch_to_user_view.
  ///
  /// In en, this message translates to:
  /// **'Switch to User View'**
  String get switch_to_user_view;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @no_notifications_yet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get no_notifications_yet;

  /// No description provided for @notif_type_service_request.
  ///
  /// In en, this message translates to:
  /// **'Service Request'**
  String get notif_type_service_request;

  /// No description provided for @notif_type_subscription_request.
  ///
  /// In en, this message translates to:
  /// **'Subscription Request'**
  String get notif_type_subscription_request;

  /// No description provided for @notif_type_activation_reminder.
  ///
  /// In en, this message translates to:
  /// **'Activation Reminder'**
  String get notif_type_activation_reminder;

  /// No description provided for @notif_type_service_update.
  ///
  /// In en, this message translates to:
  /// **'Service Update'**
  String get notif_type_service_update;

  /// No description provided for @notif_type_offer_request.
  ///
  /// In en, this message translates to:
  /// **'Offer Request'**
  String get notif_type_offer_request;

  /// No description provided for @notif_type_offer_received.
  ///
  /// In en, this message translates to:
  /// **'Offer Received'**
  String get notif_type_offer_received;

  /// No description provided for @notif_type_invite.
  ///
  /// In en, this message translates to:
  /// **'Invitation'**
  String get notif_type_invite;

  /// No description provided for @notif_type_member_remove.
  ///
  /// In en, this message translates to:
  /// **'Membership Termination'**
  String get notif_type_member_remove;

  /// No description provided for @notif_action_view_services.
  ///
  /// In en, this message translates to:
  /// **'View Services'**
  String get notif_action_view_services;

  /// No description provided for @notif_action_review_request.
  ///
  /// In en, this message translates to:
  /// **'Review Request'**
  String get notif_action_review_request;

  /// No description provided for @notif_action_view_my_requests.
  ///
  /// In en, this message translates to:
  /// **'View My Requests'**
  String get notif_action_view_my_requests;

  /// No description provided for @notif_action_view_offers.
  ///
  /// In en, this message translates to:
  /// **'View Offers'**
  String get notif_action_view_offers;

  /// No description provided for @notif_action_go_to_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Go to Dashboard'**
  String get notif_action_go_to_dashboard;

  /// No description provided for @notif_action_go_home.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get notif_action_go_home;

  /// No description provided for @app_preferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get app_preferences;

  /// No description provided for @push_notifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get push_notifications;

  /// No description provided for @localization.
  ///
  /// In en, this message translates to:
  /// **'Localization'**
  String get localization;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @startup_roles.
  ///
  /// In en, this message translates to:
  /// **'Startup & Roles'**
  String get startup_roles;

  /// No description provided for @startup_role_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically open your preferred dashboard when the app starts'**
  String get startup_role_subtitle;

  /// No description provided for @profile_updated_success.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profile_updated_success;

  /// No description provided for @subscription_required.
  ///
  /// In en, this message translates to:
  /// **'Subscription Required'**
  String get subscription_required;

  /// No description provided for @subscription_required_msg.
  ///
  /// In en, this message translates to:
  /// **'You need an active subscription to access this feature.'**
  String get subscription_required_msg;

  /// No description provided for @view_plans.
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get view_plans;

  /// No description provided for @no_products_in_stock.
  ///
  /// In en, this message translates to:
  /// **'No products in stock'**
  String get no_products_in_stock;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @system_parameters.
  ///
  /// In en, this message translates to:
  /// **'System Parameters'**
  String get system_parameters;

  /// No description provided for @appliances_count_label.
  ///
  /// In en, this message translates to:
  /// **'{count} appliances'**
  String appliances_count_label(Object count);

  /// No description provided for @total_load_watts_label.
  ///
  /// In en, this message translates to:
  /// **'{watts} W total load'**
  String total_load_watts_label(Object watts);

  /// No description provided for @total_pv_power.
  ///
  /// In en, this message translates to:
  /// **'Total PV Power'**
  String get total_pv_power;

  /// No description provided for @total_battery.
  ///
  /// In en, this message translates to:
  /// **'Total Battery'**
  String get total_battery;

  /// No description provided for @charge_controller.
  ///
  /// In en, this message translates to:
  /// **'Charge Controller'**
  String get charge_controller;

  /// No description provided for @peak_sun_hours.
  ///
  /// In en, this message translates to:
  /// **'Peak Sun Hours'**
  String get peak_sun_hours;

  /// No description provided for @autonomy.
  ///
  /// In en, this message translates to:
  /// **'Autonomy'**
  String get autonomy;

  /// No description provided for @request_notes_hint.
  ///
  /// In en, this message translates to:
  /// **'Explain why you need this service (optional)'**
  String get request_notes_hint;

  /// No description provided for @new_system.
  ///
  /// In en, this message translates to:
  /// **'New System'**
  String get new_system;

  /// No description provided for @select_system.
  ///
  /// In en, this message translates to:
  /// **'Select System'**
  String get select_system;

  /// No description provided for @add_calculation_to_existing_system.
  ///
  /// In en, this message translates to:
  /// **'Add calculation to existing system:'**
  String get add_calculation_to_existing_system;

  /// No description provided for @no_saved_systems_found.
  ///
  /// In en, this message translates to:
  /// **'No saved systems found.'**
  String get no_saved_systems_found;

  /// No description provided for @system_name.
  ///
  /// In en, this message translates to:
  /// **'System Name'**
  String get system_name;

  /// No description provided for @system_name_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., My Dream Home'**
  String get system_name_hint;

  /// No description provided for @select_installer_optional.
  ///
  /// In en, this message translates to:
  /// **'Select Installer (Optional):'**
  String get select_installer_optional;

  /// No description provided for @search_company_hint.
  ///
  /// In en, this message translates to:
  /// **'Search company...'**
  String get search_company_hint;

  /// No description provided for @confirm_request_details.
  ///
  /// In en, this message translates to:
  /// **'Confirm request details'**
  String get confirm_request_details;

  /// No description provided for @add_notes_constraints.
  ///
  /// In en, this message translates to:
  /// **'Add any notes or specific constraints...'**
  String get add_notes_constraints;

  /// No description provided for @low_voltage.
  ///
  /// In en, this message translates to:
  /// **'Low Voltage'**
  String get low_voltage;

  /// No description provided for @high_voltage.
  ///
  /// In en, this message translates to:
  /// **'High Voltage'**
  String get high_voltage;

  /// No description provided for @single_phase.
  ///
  /// In en, this message translates to:
  /// **'Single Phase'**
  String get single_phase;

  /// No description provided for @hybrid.
  ///
  /// In en, this message translates to:
  /// **'Hybrid'**
  String get hybrid;

  /// No description provided for @on_grid.
  ///
  /// In en, this message translates to:
  /// **'On-Grid'**
  String get on_grid;

  /// No description provided for @off_grid.
  ///
  /// In en, this message translates to:
  /// **'Off-Grid'**
  String get off_grid;

  /// No description provided for @lithium.
  ///
  /// In en, this message translates to:
  /// **'Lithium'**
  String get lithium;

  /// No description provided for @gel_lead_acid_tubular.
  ///
  /// In en, this message translates to:
  /// **'Gel / Lead-Acid / Tubular'**
  String get gel_lead_acid_tubular;

  /// No description provided for @panel_calc_intro.
  ///
  /// In en, this message translates to:
  /// **'Calculate the number of solar panels required based on your daily energy usage.'**
  String get panel_calc_intro;

  /// No description provided for @total_daily_usage.
  ///
  /// In en, this message translates to:
  /// **'Total Daily Usage'**
  String get total_daily_usage;

  /// No description provided for @system_efficiency_loss_factor.
  ///
  /// In en, this message translates to:
  /// **'System Efficiency / Loss Factor'**
  String get system_efficiency_loss_factor;

  /// No description provided for @required_panels.
  ///
  /// In en, this message translates to:
  /// **'Required Panels'**
  String get required_panels;

  /// No description provided for @total_array_kw.
  ///
  /// In en, this message translates to:
  /// **'Total Array: {value} kW'**
  String total_array_kw(Object value);

  /// No description provided for @did_you_know.
  ///
  /// In en, this message translates to:
  /// **'Did you know?'**
  String get did_you_know;

  /// No description provided for @panel_calc_tip_text.
  ///
  /// In en, this message translates to:
  /// **'• Ah (amp-hours) = watts ÷ voltage.\n• Example: a 1000 Wh daily load on a 12 V system equals about 83.3 Ah.\n• We include efficiency losses so the system still performs well in real conditions.'**
  String get panel_calc_tip_text;

  /// No description provided for @inverter_calc_intro.
  ///
  /// In en, this message translates to:
  /// **'Size your inverter to handle peak loads safely.'**
  String get inverter_calc_intro;

  /// No description provided for @total_load_amps.
  ///
  /// In en, this message translates to:
  /// **'Total Load Amps'**
  String get total_load_amps;

  /// No description provided for @amps.
  ///
  /// In en, this message translates to:
  /// **'Amps'**
  String get amps;

  /// No description provided for @ac_system_voltage.
  ///
  /// In en, this message translates to:
  /// **'AC System Voltage'**
  String get ac_system_voltage;

  /// No description provided for @safety_factor_oversizing.
  ///
  /// In en, this message translates to:
  /// **'Safety Factor (Over-sizing)'**
  String get safety_factor_oversizing;

  /// No description provided for @recommended_inverter_size.
  ///
  /// In en, this message translates to:
  /// **'Recommended Inverter Size'**
  String get recommended_inverter_size;

  /// No description provided for @approx_watts.
  ///
  /// In en, this message translates to:
  /// **'(Approx. {value} Watts)'**
  String approx_watts(Object value);

  /// No description provided for @inverter_calc_tip_text.
  ///
  /// In en, this message translates to:
  /// **'• Inverters are usually sized 20% to 30% above the continuous load.\n• The safety factor helps cover startup surges from motors such as refrigerators or pumps.'**
  String get inverter_calc_tip_text;

  /// No description provided for @wires_calc_intro.
  ///
  /// In en, this message translates to:
  /// **'Select the application type to get a recommended wire size.'**
  String get wires_calc_intro;

  /// No description provided for @application_type.
  ///
  /// In en, this message translates to:
  /// **'Application Type'**
  String get application_type;

  /// No description provided for @dc_solar.
  ///
  /// In en, this message translates to:
  /// **'DC Solar'**
  String get dc_solar;

  /// No description provided for @dc_battery.
  ///
  /// In en, this message translates to:
  /// **'DC Battery'**
  String get dc_battery;

  /// No description provided for @ac_single_phase.
  ///
  /// In en, this message translates to:
  /// **'AC Single Phase'**
  String get ac_single_phase;

  /// No description provided for @ac_three_phase.
  ///
  /// In en, this message translates to:
  /// **'AC Three Phase'**
  String get ac_three_phase;

  /// No description provided for @volts.
  ///
  /// In en, this message translates to:
  /// **'Volts'**
  String get volts;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @distance_one_way.
  ///
  /// In en, this message translates to:
  /// **'Distance (One Way)'**
  String get distance_one_way;

  /// No description provided for @metres.
  ///
  /// In en, this message translates to:
  /// **'Metres'**
  String get metres;

  /// No description provided for @allowable_voltage_drop.
  ///
  /// In en, this message translates to:
  /// **'Allowable Voltage Drop'**
  String get allowable_voltage_drop;

  /// No description provided for @recommended_wire_size.
  ///
  /// In en, this message translates to:
  /// **'Recommended Wire Size'**
  String get recommended_wire_size;

  /// No description provided for @wires_calc_tip_text.
  ///
  /// In en, this message translates to:
  /// **'• Keeping voltage drop low is critical for system efficiency.\n• For battery cables, aim for less than 1% drop to avoid inverter cut-offs.\n• For solar PV runs, 3% is generally acceptable.'**
  String get wires_calc_tip_text;

  /// No description provided for @pump_calc_intro.
  ///
  /// In en, this message translates to:
  /// **'Calculate the solar power needed for your water pump system.'**
  String get pump_calc_intro;

  /// No description provided for @daily_water_volume.
  ///
  /// In en, this message translates to:
  /// **'Daily Water Volume'**
  String get daily_water_volume;

  /// No description provided for @total_dynamic_head.
  ///
  /// In en, this message translates to:
  /// **'Total Dynamic Head (TDH)'**
  String get total_dynamic_head;

  /// No description provided for @pumping_hours.
  ///
  /// In en, this message translates to:
  /// **'Pumping Hours'**
  String get pumping_hours;

  /// No description provided for @location_peak_sun_hours.
  ///
  /// In en, this message translates to:
  /// **'Location Peak Sun Hours (PSH)'**
  String get location_peak_sun_hours;

  /// No description provided for @solar_panel_wattage.
  ///
  /// In en, this message translates to:
  /// **'Solar Panel Wattage'**
  String get solar_panel_wattage;

  /// No description provided for @pump_efficiency.
  ///
  /// In en, this message translates to:
  /// **'Pump Efficiency'**
  String get pump_efficiency;

  /// No description provided for @required_solar_panels.
  ///
  /// In en, this message translates to:
  /// **'Required Solar Panels'**
  String get required_solar_panels;

  /// No description provided for @hydraulic_power_est.
  ///
  /// In en, this message translates to:
  /// **'Hydraulic Power Estimate'**
  String get hydraulic_power_est;

  /// No description provided for @motor_hp_estimate.
  ///
  /// In en, this message translates to:
  /// **'(~{value} HP) Motor'**
  String motor_hp_estimate(Object value);

  /// No description provided for @definitions.
  ///
  /// In en, this message translates to:
  /// **'Definitions'**
  String get definitions;

  /// No description provided for @flow_rate.
  ///
  /// In en, this message translates to:
  /// **'Flow Rate'**
  String get flow_rate;

  /// No description provided for @hydraulic_power.
  ///
  /// In en, this message translates to:
  /// **'Hydraulic Power'**
  String get hydraulic_power;

  /// No description provided for @definition_tdh.
  ///
  /// In en, this message translates to:
  /// **'Vertical lift + friction losses + required pressure.'**
  String get definition_tdh;

  /// No description provided for @definition_flow_rate.
  ///
  /// In en, this message translates to:
  /// **'The amount of water needed each day, for example in cubic meters.'**
  String get definition_flow_rate;

  /// No description provided for @definition_psh.
  ///
  /// In en, this message translates to:
  /// **'Equivalent hours of full solar intensity at your location, usually around 4 to 6 hours.'**
  String get definition_psh;

  /// No description provided for @definition_hydraulic_power.
  ///
  /// In en, this message translates to:
  /// **'The power required to lift the water before motor efficiency losses are applied.'**
  String get definition_hydraulic_power;

  /// No description provided for @find_battery_count.
  ///
  /// In en, this message translates to:
  /// **'Find Battery Count'**
  String get find_battery_count;

  /// No description provided for @find_backup_time.
  ///
  /// In en, this message translates to:
  /// **'Find Backup Time'**
  String get find_backup_time;

  /// No description provided for @how_many_batteries_need.
  ///
  /// In en, this message translates to:
  /// **'How many batteries do you need?'**
  String get how_many_batteries_need;

  /// No description provided for @how_long_batteries_last.
  ///
  /// In en, this message translates to:
  /// **'How long will your batteries last?'**
  String get how_long_batteries_last;

  /// No description provided for @required_backup_time.
  ///
  /// In en, this message translates to:
  /// **'Required Backup Time'**
  String get required_backup_time;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @required_batteries.
  ///
  /// In en, this message translates to:
  /// **'Required Batteries'**
  String get required_batteries;

  /// No description provided for @batteries_count_value.
  ///
  /// In en, this message translates to:
  /// **'{count} Batteries'**
  String batteries_count_value(Object count);

  /// No description provided for @battery_for_spec.
  ///
  /// In en, this message translates to:
  /// **'For {capacity}Ah @ {voltage}V'**
  String battery_for_spec(Object capacity, Object voltage);

  /// No description provided for @estimated_runtime.
  ///
  /// In en, this message translates to:
  /// **'Estimated Runtime'**
  String get estimated_runtime;

  /// No description provided for @runtime_hours_value.
  ///
  /// In en, this message translates to:
  /// **'{value} Hours'**
  String runtime_hours_value(Object value);

  /// No description provided for @number_of_batteries.
  ///
  /// In en, this message translates to:
  /// **'Number of Batteries'**
  String get number_of_batteries;

  /// No description provided for @battery_capacity_ah.
  ///
  /// In en, this message translates to:
  /// **'Battery Capacity (Ah)'**
  String get battery_capacity_ah;

  /// No description provided for @depth_of_discharge_dod.
  ///
  /// In en, this message translates to:
  /// **'Depth of Discharge (DoD)'**
  String get depth_of_discharge_dod;

  /// No description provided for @typical_dod_hint.
  ///
  /// In en, this message translates to:
  /// **'Typical: 50% for Gel/AGM, 80% for Lithium, 20-30% for Lead-Acid'**
  String get typical_dod_hint;

  /// No description provided for @battery_count_formula_hint.
  ///
  /// In en, this message translates to:
  /// **'Formula: (Load × Time) ÷ (Battery Voltage × Capacity × DoD)'**
  String get battery_count_formula_hint;

  /// No description provided for @battery_runtime_formula_hint.
  ///
  /// In en, this message translates to:
  /// **'Calculates how long the battery bank can sustain the load before reaching the selected depth of discharge.'**
  String get battery_runtime_formula_hint;

  /// No description provided for @battery_calculator_title.
  ///
  /// In en, this message translates to:
  /// **'Battery Calculator'**
  String get battery_calculator_title;

  /// No description provided for @time_calculate.
  ///
  /// In en, this message translates to:
  /// **'Time Calculate'**
  String get time_calculate;

  /// No description provided for @count_calculate.
  ///
  /// In en, this message translates to:
  /// **'Count Calculate'**
  String get count_calculate;

  /// No description provided for @your_load_ampere.
  ///
  /// In en, this message translates to:
  /// **'Your Load Ampere'**
  String get your_load_ampere;

  /// No description provided for @example_10.
  ///
  /// In en, this message translates to:
  /// **'e.g., 10'**
  String get example_10;

  /// No description provided for @numbers_only.
  ///
  /// In en, this message translates to:
  /// **'Numbers only'**
  String get numbers_only;

  /// No description provided for @load_ampere_helper.
  ///
  /// In en, this message translates to:
  /// **'Enter the load in amperes and select the AC system voltage. Load is usually calculated as voltage × current. Example: 10 A × 230 V = 2300 W.'**
  String get load_ampere_helper;

  /// No description provided for @battery_amperes.
  ///
  /// In en, this message translates to:
  /// **'Battery Capacity'**
  String get battery_amperes;

  /// No description provided for @battery_voltage_label.
  ///
  /// In en, this message translates to:
  /// **'Battery Voltage'**
  String get battery_voltage_label;

  /// No description provided for @battery_count_label.
  ///
  /// In en, this message translates to:
  /// **'Battery Count'**
  String get battery_count_label;

  /// No description provided for @battery_count_hint.
  ///
  /// In en, this message translates to:
  /// **'One or more'**
  String get battery_count_hint;

  /// No description provided for @runtime_question.
  ///
  /// In en, this message translates to:
  /// **'How many hours do you need the system to run on batteries?'**
  String get runtime_question;

  /// No description provided for @required_runtime_hours.
  ///
  /// In en, this message translates to:
  /// **'Required Runtime (hours)'**
  String get required_runtime_hours;

  /// No description provided for @example_100_or_200.
  ///
  /// In en, this message translates to:
  /// **'e.g., 100 or 200'**
  String get example_100_or_200;

  /// No description provided for @example_12_24_48_512.
  ///
  /// In en, this message translates to:
  /// **'e.g., 12, 24, 48, or 51.2'**
  String get example_12_24_48_512;

  /// No description provided for @example_5_or_8.
  ///
  /// In en, this message translates to:
  /// **'e.g., 5 or 8'**
  String get example_5_or_8;

  /// No description provided for @battery_count_explanation.
  ///
  /// In en, this message translates to:
  /// **'The number of batteries needed is calculated as:\n\n(Power × Time) ÷ (Battery Voltage × Capacity × DoD)\n\nExample: (2300 W × 5 h) ÷ (12 V × 100 Ah × 0.2) = about 8 batteries.\n\nThis helps estimate how many batteries are needed for a specific load and runtime.'**
  String get battery_count_explanation;

  /// No description provided for @depth_of_discharge_with_value.
  ///
  /// In en, this message translates to:
  /// **'Battery Depth of Discharge ({value}%)'**
  String depth_of_discharge_with_value(Object value);

  /// No description provided for @dod_guidance.
  ///
  /// In en, this message translates to:
  /// **'Set the depth of discharge (DoD).\n\nTypical values range from 20% to 80% depending on battery type.\n\n• 20% for Lithium or Tubular\n• 50% for AGM or Gel\nCheck the battery datasheet for the best accuracy.'**
  String get dod_guidance;

  /// No description provided for @battery_runtime_explanation.
  ///
  /// In en, this message translates to:
  /// **'Enter the battery capacity (Ah), voltage (V), and number of batteries.\nThe total stored energy is calculated as:\nVoltage × Capacity × Number of Batteries × Depth of Discharge.\n\n• Example: 4 batteries × 12 V × 100 Ah × 0.2 = 960 Wh\nThis helps estimate how long the battery system can power your load.'**
  String get battery_runtime_explanation;

  /// No description provided for @dod_guidance_runtime.
  ///
  /// In en, this message translates to:
  /// **'Set the battery depth of discharge (DoD).\n\nTypical values usually range between 50% and 80% depending on battery type, temperature, and manufacturer guidance.\n\n• Use 20% for Lithium or Tubular batteries.\n• Use 50% for AGM or Gel batteries.\nRefer to the datasheet if you are unsure.'**
  String get dod_guidance_runtime;

  /// No description provided for @runtime_hours_precise.
  ///
  /// In en, this message translates to:
  /// **'{value} hours'**
  String runtime_hours_precise(Object value);

  /// No description provided for @save_to_system.
  ///
  /// In en, this message translates to:
  /// **'Save to System'**
  String get save_to_system;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @deleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Delete Product'**
  String get deleteProduct;

  /// No description provided for @costPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost Price'**
  String get costPrice;

  /// No description provided for @stockQuantity.
  ///
  /// In en, this message translates to:
  /// **'Stock Quantity'**
  String get stockQuantity;

  /// No description provided for @minStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Min Stock Alert'**
  String get minStockAlert;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @confirmDeleteProduct.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product?'**
  String get confirmDeleteProduct;

  /// No description provided for @productDeleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get productDeleted;

  /// No description provided for @productCreated.
  ///
  /// In en, this message translates to:
  /// **'Product created successfully'**
  String get productCreated;

  /// No description provided for @productUpdated.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get productUpdated;

  /// No description provided for @addOption.
  ///
  /// In en, this message translates to:
  /// **'Add Option'**
  String get addOption;

  /// No description provided for @addTier.
  ///
  /// In en, this message translates to:
  /// **'Add Tier'**
  String get addTier;

  /// No description provided for @isRequired.
  ///
  /// In en, this message translates to:
  /// **'Is Required'**
  String get isRequired;

  /// No description provided for @noProducts.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProducts;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @productImages.
  ///
  /// In en, this message translates to:
  /// **'Product Images'**
  String get productImages;

  /// No description provided for @pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricing;

  /// No description provided for @productOptions.
  ///
  /// In en, this message translates to:
  /// **'Product Options'**
  String get productOptions;

  /// No description provided for @saveProduct.
  ///
  /// In en, this message translates to:
  /// **'Save Product'**
  String get saveProduct;

  /// No description provided for @productSaved.
  ///
  /// In en, this message translates to:
  /// **'Product saved successfully'**
  String get productSaved;

  /// No description provided for @noTiers.
  ///
  /// In en, this message translates to:
  /// **'No tiers added yet'**
  String get noTiers;

  /// No description provided for @noOptions.
  ///
  /// In en, this message translates to:
  /// **'No options added yet'**
  String get noOptions;

  /// No description provided for @optionName.
  ///
  /// In en, this message translates to:
  /// **'Option Name'**
  String get optionName;

  /// No description provided for @add_image.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get add_image;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @request_service.
  ///
  /// In en, this message translates to:
  /// **'Request Service'**
  String get request_service;

  /// No description provided for @request_service_title.
  ///
  /// In en, this message translates to:
  /// **'Request {service} Access'**
  String request_service_title(Object service);

  /// No description provided for @service_code.
  ///
  /// In en, this message translates to:
  /// **'Service Code'**
  String get service_code;

  /// No description provided for @service_code_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., offers, inventory, storefront'**
  String get service_code_hint;

  /// No description provided for @service_code_required.
  ///
  /// In en, this message translates to:
  /// **'Service code is required'**
  String get service_code_required;

  /// No description provided for @request_notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get request_notes;

  /// No description provided for @request_notes_hint_text.
  ///
  /// In en, this message translates to:
  /// **'Provide details about your requirements...'**
  String get request_notes_hint_text;

  /// No description provided for @request_image.
  ///
  /// In en, this message translates to:
  /// **'Screenshot/Image'**
  String get request_image;

  /// No description provided for @request_image_hint.
  ///
  /// In en, this message translates to:
  /// **'Upload a screenshot or image (optional)'**
  String get request_image_hint;

  /// No description provided for @remove_image.
  ///
  /// In en, this message translates to:
  /// **'Remove Image'**
  String get remove_image;

  /// No description provided for @submitting_request.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get submitting_request;

  /// No description provided for @request_submitted_success.
  ///
  /// In en, this message translates to:
  /// **'Service request submitted successfully!'**
  String get request_submitted_success;

  /// No description provided for @request_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit request'**
  String get request_failed;

  /// No description provided for @select_image_source.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get select_image_source;

  /// No description provided for @service_not_active.
  ///
  /// In en, this message translates to:
  /// **'Service Not Active'**
  String get service_not_active;

  /// No description provided for @service_not_active_desc.
  ///
  /// In en, this message translates to:
  /// **'This service is not currently available for your company.'**
  String get service_not_active_desc;

  /// No description provided for @request_access.
  ///
  /// In en, this message translates to:
  /// **'Request Access'**
  String get request_access;

  /// No description provided for @learn_more.
  ///
  /// In en, this message translates to:
  /// **'Learn More'**
  String get learn_more;

  /// No description provided for @service_request_pending.
  ///
  /// In en, this message translates to:
  /// **'Request Pending'**
  String get service_request_pending;

  /// No description provided for @service_request_pending_desc.
  ///
  /// In en, this message translates to:
  /// **'Your request for {service} is pending approval.'**
  String service_request_pending_desc(Object service);

  /// No description provided for @view_request_status.
  ///
  /// In en, this message translates to:
  /// **'View Request Status'**
  String get view_request_status;

  /// No description provided for @service_maintenance_mode.
  ///
  /// In en, this message translates to:
  /// **'Service Under Maintenance'**
  String get service_maintenance_mode;

  /// No description provided for @service_maintenance_mode_desc.
  ///
  /// In en, this message translates to:
  /// **'{service} is currently being updated with new features.'**
  String service_maintenance_mode_desc(Object service);

  /// No description provided for @check_back_later.
  ///
  /// In en, this message translates to:
  /// **'Please check back later for improvements.'**
  String get check_back_later;

  /// No description provided for @open_service.
  ///
  /// In en, this message translates to:
  /// **'Open {service}'**
  String open_service(Object service);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
