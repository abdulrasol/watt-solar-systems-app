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

  /// No description provided for @buy_components.
  ///
  /// In en, this message translates to:
  /// **'Buy components'**
  String get buy_components;

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
  /// **'LOGIN'**
  String get login;

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

  /// No description provided for @phone_number.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone_number;

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
  /// **'Start Your Solar Business'**
  String get start_your_solar_business;

  /// No description provided for @register_company_details.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details below to register your company. Your application will be reviewed by our admin team.'**
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

  /// No description provided for @company_profile.
  ///
  /// In en, this message translates to:
  /// **'Company Profile'**
  String get company_profile;

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

  /// No description provided for @edit_company.
  ///
  /// In en, this message translates to:
  /// **'Edit Company'**
  String get edit_company;

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
  /// **'Specific installation constraints, location notes, or other requests...'**
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

  /// No description provided for @required_field.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required_field;

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
