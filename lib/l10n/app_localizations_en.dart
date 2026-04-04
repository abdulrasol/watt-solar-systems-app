// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Watt';

  @override
  String get app_slug => 'Calculate Your Solar System';

  @override
  String get profile => 'Profile';

  @override
  String get my_systems => 'My Systems';

  @override
  String get my_requests => 'My Requests';

  @override
  String get my_orders => 'My Orders';

  @override
  String get company_dashboard => 'Company Workspace';

  @override
  String get admin_dashboard => 'Admin Workspace';

  @override
  String get register_company => 'Register Company';

  @override
  String get settings => 'Settings';

  @override
  String get guest_user => 'Guest User';

  @override
  String get welcome_guest => 'Welcome, guest';

  @override
  String get hello => 'Hello,';

  @override
  String get dark_mode => 'Dark Mode';

  @override
  String get sign_out => 'Sign Out';

  @override
  String get sign_in => 'Sign In';

  @override
  String get home => 'Home';

  @override
  String get good_morning => 'Good morning,';

  @override
  String get good_afternoon => 'Good afternoon,';

  @override
  String get good_evening => 'Good evening,';

  @override
  String get ready_to_manage_solar => 'Ready to manage your solar systems?';

  @override
  String get active_orders => 'Active Orders';

  @override
  String get quick_actions => 'Quick Actions';

  @override
  String get calculator => 'Calculator';

  @override
  String get plan_your_system => 'Plan your system';

  @override
  String get solar_tips => 'Solar Tips & Hints';

  @override
  String get store => 'Store';

  @override
  String get buy_components => 'Buy components';

  @override
  String get b2b_storefront => 'B2B Storefront';

  @override
  String get b2c_storefront => 'B2C Storefront';

  @override
  String get storefront_b2b_subtitle => 'Member-only catalog with wholesale pricing and company inventory visibility.';

  @override
  String get storefront_b2c_subtitle => 'Open storefront for all users with public product access.';

  @override
  String storefront_products_available(Object count) {
    return '$count products available';
  }

  @override
  String get search_products => 'Search products';

  @override
  String get search_b2b_products => 'Search B2B products';

  @override
  String get filters => 'Filters';

  @override
  String get sort_by => 'Sort By';

  @override
  String get sort_newest => 'Newest';

  @override
  String get sort_oldest => 'Oldest';

  @override
  String get sort_name_asc => 'Name A-Z';

  @override
  String get sort_name_desc => 'Name Z-A';

  @override
  String get sort_price_asc => 'Price Low-High';

  @override
  String get sort_price_desc => 'Price High-Low';

  @override
  String get all => 'All';

  @override
  String get all_categories => 'All Categories';

  @override
  String get all_companies => 'All companies';

  @override
  String get availability => 'Availability';

  @override
  String get available => 'Available';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get min_price => 'Min price';

  @override
  String get max_price => 'Max price';

  @override
  String get clear_filters => 'Clear';

  @override
  String get apply_filters => 'Apply';

  @override
  String get store_filters => 'Store Filters';

  @override
  String get no_store_products_found => 'No products matched the current filters.';

  @override
  String get load_more => 'Load More';

  @override
  String get global_category => 'Global';

  @override
  String get internal_category => 'Internal';

  @override
  String get company_category => 'Company';

  @override
  String iqd_price(Object amount) {
    return 'IQD $amount';
  }

  @override
  String retail_price_label(Object amount) {
    return 'Retail $amount';
  }

  @override
  String wholesale_price_label(Object amount) {
    return 'Wholesale $amount';
  }

  @override
  String stock_count(Object count) {
    return 'Stock $count';
  }

  @override
  String get product_details => 'Product Details';

  @override
  String get price_overview => 'Price Overview';

  @override
  String get display_price => 'Display Price';

  @override
  String get retail_price => 'Retail Price';

  @override
  String get wholesale_price => 'Wholesale Price';

  @override
  String get sku => 'SKU';

  @override
  String get pricing_tiers => 'Pricing Tiers';

  @override
  String pricing_tier_line(Object quantity, Object amount) {
    return '$quantity+ units: IQD $amount';
  }

  @override
  String get add_to_cart => 'Add to Cart';

  @override
  String get added_to_cart => 'Added to cart';

  @override
  String get b2b_cart => 'B2B Cart';

  @override
  String get b2c_cart => 'B2C Cart';

  @override
  String get cart_empty => 'Your cart is empty';

  @override
  String get cart_empty_subtitle => 'Add products from the storefront to create a local cart for each company.';

  @override
  String get cart_summary => 'Cart Summary';

  @override
  String get total_items => 'Total Items';

  @override
  String get total_amount => 'Total Amount';

  @override
  String cart_items_count(Object count) {
    return '$count items';
  }

  @override
  String get clear_cart => 'Clear Cart';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get join_community => 'Join the Community';

  @override
  String get share_system_feedback => 'Share your system & get feedback';

  @override
  String get reset_password => 'Reset Password';

  @override
  String get reset_password_instructions => 'Enter your email address and we will send you a link to reset your password.';

  @override
  String get email_is_required => 'Email is required';

  @override
  String get invalid_email => 'Invalid email';

  @override
  String get email => 'Email';

  @override
  String get success => 'Success';

  @override
  String get password_reset_email_sent => 'Password reset email sent!';

  @override
  String get error => 'Error';

  @override
  String get send_reset_link => 'Send Reset Link';

  @override
  String get send_feedback => 'Send Feedback';

  @override
  String get feedback_info_title => 'Your feedback helps us improve';

  @override
  String get feedback_info_description => 'Share your feedback or suggestions so we can improve the app and make your experience better.';

  @override
  String get name => 'Name';

  @override
  String get name_hint => 'Enter your name';

  @override
  String get name_required => 'Please enter your name';

  @override
  String get phone_number => 'Phone Number';

  @override
  String get phone_hint => 'Phone number (optional)';

  @override
  String get message => 'Message';

  @override
  String get feedback_hint => 'Write your feedback or suggestions here';

  @override
  String get feedback_required => 'Please enter a message';

  @override
  String get feedback_submitted_successfully => 'Feedback submitted successfully!';

  @override
  String get user_feedbacks => 'User Feedback';

  @override
  String get no_feedbacks_yet => 'No feedback yet';

  @override
  String get mark_as_read => 'Mark as Read';

  @override
  String get mark_as_unread => 'Mark as Unread';

  @override
  String get call => 'Call';

  @override
  String get whatsapp => 'WhatsApp';

  @override
  String get delete_feedback => 'Delete Feedback';

  @override
  String get delete_feedback_confirm => 'Are you sure you want to delete this feedback? This action cannot be undone.';

  @override
  String get add_screenshot => 'Add Screenshot';

  @override
  String get tap_to_select_image => 'Tap to select an image';

  @override
  String get remove => 'Remove';

  @override
  String get username => 'Username';

  @override
  String get username_is_required => 'Username is required';

  @override
  String get password => 'Password';

  @override
  String get password_is_required => 'Password is required';

  @override
  String get forgot_password => 'Forgot Password?';

  @override
  String get login => 'Sign In';

  @override
  String get sign_up => 'Sign Up';

  @override
  String get or_text => 'OR';

  @override
  String get first_name => 'First Name';

  @override
  String get last_name => 'Last Name';

  @override
  String get phone_required => 'Phone number is required';

  @override
  String get invalid_phone_number => 'Enter a valid phone number';

  @override
  String get loading => 'Loading...';

  @override
  String get country => 'Country';

  @override
  String get city => 'City';

  @override
  String get city_is_required => 'City is required';

  @override
  String get confirm_password => 'Confirm Password';

  @override
  String get confirm_password_is_required => 'Confirm password is required';

  @override
  String get passwords_do_not_match => 'Passwords do not match';

  @override
  String get account_created => 'Account Created';

  @override
  String get please_verify_email => 'Please verify your email address.';

  @override
  String get sign_up_failed => 'Sign Up Failed';

  @override
  String get start_your_solar_business => 'Start your solar business';

  @override
  String get register_company_details => 'Fill in the details below to register your company. Our team will review your application before approval.';

  @override
  String get company_name => 'Company Name';

  @override
  String get company_name_is_required => 'Company Name is required';

  @override
  String get description => 'Description';

  @override
  String get description_is_required => 'Description is required';

  @override
  String get b2b => 'B2B';

  @override
  String get b2c => 'B2C';

  @override
  String get address => 'Address';

  @override
  String get address_is_required => 'Address is required';

  @override
  String get upload_logo => 'Upload Logo';

  @override
  String get business_phone => 'Business Phone';

  @override
  String get submit_application => 'Submit Application';

  @override
  String get company_registered_success => 'Company registered successfully';

  @override
  String get min_6_characters => 'Minimum 6 characters';

  @override
  String get edit_profile_title => 'Edit Profile';

  @override
  String get edit_profile_tooltip => 'Edit Profile';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String failed_to_pick_image(Object error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get tap_to_change_avatar => 'Tap to change avatar';

  @override
  String get security_question => 'Security Question';

  @override
  String get security_answer => 'Security Answer';

  @override
  String get save_changes => 'Save Changes';

  @override
  String get saving => 'Saving...';

  @override
  String get my_posts => 'My Posts';

  @override
  String profile_id_short(Object id) {
    return 'ID: $id...';
  }

  @override
  String get welcome_back => 'Welcome back';

  @override
  String get choose_how_to_continue => 'Choose how you want to continue';

  @override
  String get solar_hub => 'Solar Hub';

  @override
  String continue_as(Object name) {
    return 'Continue as $name';
  }

  @override
  String get platform_management => 'Manage the platform';

  @override
  String get save_role_page_selection => 'Remember this choice';

  @override
  String get use_the_power_of_the_sun => 'Smarter solar starts here';

  @override
  String get default_user => 'User';

  @override
  String get calculator_tools => 'Calculator Tools';

  @override
  String get system_wizard => 'System Calculator Wizard';

  @override
  String get system_wizard_desc => 'Answer a few questions to get a complete system recommendation';

  @override
  String get request_offer_wizard => 'Request Custom Offer';

  @override
  String get request_offer_desc => 'Submit your specific requirements to get offers from companies';

  @override
  String get quick_tools => 'Quick Tools';

  @override
  String get panels_calc => 'Panels';

  @override
  String get inverter_calc => 'Inverter';

  @override
  String get battery_calc => 'Battery';

  @override
  String get wires_calc => 'Wires';

  @override
  String get pump_calc => 'Water Pump';

  @override
  String get step_appliances => 'Appliances';

  @override
  String get step_usage => 'Usage';

  @override
  String get step_results => 'Results';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get close => 'Close';

  @override
  String get calculate => 'Calculate';

  @override
  String get add_appliance => 'Add Appliance';

  @override
  String get autonomy_hours => 'Autonomy Hours';

  @override
  String get sun_hours => 'Sun Peak Hours';

  @override
  String get panel_wattage => 'Panel Wattage';

  @override
  String get single_battery_voltage => 'Single Battery Voltage';

  @override
  String get battery_type_hint => 'Lithium usually 12.8V, 25.6V, 51.2V | Lead-Acid usually 12V';

  @override
  String get system_voltage => 'System Voltage';

  @override
  String get recommended_system => 'Recommended System';

  @override
  String get panel_count => 'Panel Count';

  @override
  String get inverter_size => 'Inverter Size';

  @override
  String get battery_bank => 'Battery Bank';

  @override
  String get request_this_system => 'Request This System';

  @override
  String get request_description => 'Send this system configuration to local companies to get offers';

  @override
  String get guide => 'Guide';

  @override
  String get dont_show_again => 'Don\'t show this again';

  @override
  String get capacity_kw => 'Capacity';

  @override
  String get voltage_type => 'Voltage Type';

  @override
  String get phase => 'Phase';

  @override
  String get type => 'Type';

  @override
  String get battery_voltage => 'Battery Voltage';

  @override
  String get battery_amp => 'Capacity';

  @override
  String get count => 'Count';

  @override
  String get bank => 'Bank';

  @override
  String get notes_details => 'Notes & Details';

  @override
  String get submit_request => 'Submit Request';

  @override
  String get notes_optional => 'Notes (optional)';

  @override
  String get notes_brand => 'Notes (Brand, specific type...)';

  @override
  String get three_phase => 'Three Phase';

  @override
  String get voltage_110 => '110 V';

  @override
  String get voltage_230 => '230 V';

  @override
  String get voltage_380_three_phase => '380 V (Three-phase)';

  @override
  String get confirm_submit => 'Confirm Submit';

  @override
  String get create_new_system => 'Create New System';

  @override
  String get enter_system_name => 'Enter a name for your new system:';

  @override
  String get back_to_list => 'Back to List';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get error_enter_system_name => 'Required: Please enter a system name';

  @override
  String get error_select_system => 'Required: Please select a system';

  @override
  String get error_no_components => 'Please add at least one component (Panel, Inverter, or Battery)';

  @override
  String get appliance_name => 'Appliance Name';

  @override
  String get power_watts => 'Power';

  @override
  String get quantity => 'Quantity';

  @override
  String get hours_per_day => 'Hours/Day';

  @override
  String get no_company_found => 'No Company Found';

  @override
  String get not_linked_company => 'You are not linked to any company yet.';

  @override
  String get verification_pending => 'Verification Pending';

  @override
  String get verification_pending_msg => 'Your company registration is under review. Please check back later.';

  @override
  String get go_back => 'Go Back';

  @override
  String get balance => 'Balance';

  @override
  String get stock_value => 'Stock Value';

  @override
  String get pending_orders => 'Pending Orders';

  @override
  String get open_requests => 'Open Requests';

  @override
  String get low_stock => 'Low Stock';

  @override
  String get manage_business => 'Manage Business';

  @override
  String get orders => 'Orders';

  @override
  String get pos => 'Point of Sale';

  @override
  String get invoices => 'Invoices';

  @override
  String get accounting => 'Accounting';

  @override
  String get inventory => 'Inventory';

  @override
  String get offers => 'Offers';

  @override
  String get people => 'People';

  @override
  String get members => 'Members';

  @override
  String get customers => 'Customers';

  @override
  String get suppliers => 'Suppliers';

  @override
  String get my_purchases => 'My Purchases';

  @override
  String get tools => 'Tools';

  @override
  String get analytics => 'Analytics';

  @override
  String get overview => 'Overview';

  @override
  String get services => 'Services';

  @override
  String get contacts => 'Contacts';

  @override
  String get status_active => 'Active';

  @override
  String get status_pending => 'Pending';

  @override
  String get status_rejected => 'Rejected';

  @override
  String get status_suspended => 'Suspended';

  @override
  String get status_cancelled => 'Cancelled';

  @override
  String get status_accepted => 'Accepted';

  @override
  String get status_completed => 'Completed';

  @override
  String get status_unavailable => 'Unavailable';

  @override
  String get request_status_open => 'Open';

  @override
  String get request_status_closed => 'Closed';

  @override
  String get request_status_fulfilled => 'Fulfilled';

  @override
  String get battery_type_gel => 'Gel';

  @override
  String get battery_type_tubular => 'Tubular';

  @override
  String get battery_type_lithium => 'Lithium';

  @override
  String get inverter_type_off_grid => 'Off Grid';

  @override
  String get inverter_type_on_grid => 'On Grid';

  @override
  String get inverter_type_hybrid => 'Hybrid';

  @override
  String get offers_marketplace => 'Solar Marketplace';

  @override
  String get available_requests => 'Available Requests';

  @override
  String get my_bids => 'My Bids';

  @override
  String get no_requests_found => 'No requests found';

  @override
  String get no_offers_found => 'No offers found';

  @override
  String get new_projects_will_appear_here => 'New solar projects in your area will appear here.';

  @override
  String get browse_requests_to_start_bidding => 'Browse the requests tab to start bidding on projects.';

  @override
  String get admin_marketplace_oversight => 'Admin: Marketplace Oversight';

  @override
  String get all_requests => 'All Requests';

  @override
  String get all_offers => 'All Offers';

  @override
  String get my_solar_project_inquiries => 'My Solar Project Inquiries';

  @override
  String get add_new_request => 'Add New Request';

  @override
  String received_offers_count(Object count) {
    return 'Received Offers ($count)';
  }

  @override
  String get no_offers_received_yet => 'No offers received yet.';

  @override
  String get no_requests_posted => 'No requests posted';

  @override
  String get post_first_solar_request => 'Ready to save on energy? Post your first solar request and get bids from solar companies.';

  @override
  String get create_solar_request => 'Create Solar Request';

  @override
  String get location_preferences => 'Location Preferences';

  @override
  String get broadcast_to_all_cities => 'Broadcast to All Cities';

  @override
  String get broadcast_to_all_cities_desc => 'Enable to reach companies nationwide';

  @override
  String get solar_panel_needs => 'Solar Panel Needs';

  @override
  String get expected_power_per_unit => 'Expected Power/Unit (W)';

  @override
  String get quantity_needed => 'Quantity Needed';

  @override
  String get estimated_pv_power_needed => 'Estimated PV Power Needed';

  @override
  String get storage_requirements => 'Storage Requirements';

  @override
  String get preferred_battery_type => 'Preferred Battery Type';

  @override
  String get battery_size_wh => 'Battery Size (Wh)';

  @override
  String get total_energy_capacity_needed => 'Total Energy Capacity Needed';

  @override
  String get inverter_configuration => 'Inverter Configuration';

  @override
  String get desired_inverter_type => 'Desired Inverter Type';

  @override
  String get total_inverter_power_peak => 'Total Inverter Power Peak';

  @override
  String get additional_specifications => 'Additional Specifications';

  @override
  String get project_description_notes => 'Project Description / Notes';

  @override
  String get required_field => 'Required';

  @override
  String get post_solar_request => 'Post Solar Request';

  @override
  String get new_offer_proposal => 'New Offer Proposal';

  @override
  String get financial_information => 'Financial Information';

  @override
  String get solar_panels => 'Solar Panels';

  @override
  String get power_per_unit => 'Power/Unit (W)';

  @override
  String get total_energy_capacity => 'Total Energy Capacity';

  @override
  String get battery_type_label => 'Battery Type';

  @override
  String get inverter_type_label => 'Inverter Type';

  @override
  String get storage_batteries => 'Storage (Batteries)';

  @override
  String get additional_notes => 'Additional Notes';

  @override
  String get notes_for_user => 'Notes for the User';

  @override
  String get enter_quotation_price => 'Enter quotation price';

  @override
  String get price_required => 'Price is required';

  @override
  String get submit_quotation => 'Submit Quotation';

  @override
  String get offer_details => 'Offer Details';

  @override
  String get offering_price => 'Offering Price';

  @override
  String get technical_specifications => 'Technical Specifications';

  @override
  String get included_services_items => 'Included Services & Items';

  @override
  String get notes_from_provider => 'Notes from Provider';

  @override
  String submitted_on_date(Object date) {
    return 'Submitted on $date';
  }

  @override
  String get quotation => 'Quotation';

  @override
  String get panels => 'Panels';

  @override
  String get battery_storage => 'Battery & Storage';

  @override
  String get total_project_quote => 'Total Project Quote';

  @override
  String get chat => 'Chat';

  @override
  String get accept_offer => 'Accept Offer';

  @override
  String get reject_offer => 'Reject Offer';

  @override
  String get solar_request_details => 'Solar Request Details';

  @override
  String get user_needs => 'User Needs';

  @override
  String get technical_notes => 'Technical Notes';

  @override
  String get send_offer_for_request => 'Send Offer for this Request';

  @override
  String get panels_power => 'Panels Power';

  @override
  String get battery_power => 'Battery Power';

  @override
  String get battery_type_full => 'Battery Type';

  @override
  String get pv_power => 'PV Power';

  @override
  String get battery => 'Battery';

  @override
  String city_label(Object city) {
    return 'City: $city';
  }

  @override
  String get company_dashboard_subtitle => 'Manage your solar operations efficiently';

  @override
  String get error_loading_data => 'Error loading data';

  @override
  String section_label(Object name) {
    return 'Section: $name';
  }

  @override
  String get quick_stats => 'Quick Stats';

  @override
  String get ready_to_scale_business => 'Ready to scale your business?';

  @override
  String get monitor_growth_subscriptions => 'Monitor your growth and subscriptions here.';

  @override
  String get solar_solutions_provider => 'Solar Solutions Provider';

  @override
  String get standard => 'Standard';

  @override
  String get company => 'Company';

  @override
  String get admin_user => 'Admin User';

  @override
  String get super_admin => 'Super Admin';

  @override
  String get ready_to_scale_title => 'Ready to Scale?';

  @override
  String service_not_requested(Object service) {
    return 'You have not requested access to $service yet.';
  }

  @override
  String get service_unlock_description => 'Unlock this service to enhance your solar business and automate your workflow.';

  @override
  String get access_requested_successfully => 'Access requested successfully!';

  @override
  String get request_access_now => 'Request Access Now';

  @override
  String get awaiting_approval => 'Awaiting Approval';

  @override
  String service_under_review(Object service) {
    return 'Your application for $service is currently under review.';
  }

  @override
  String get service_pending_help => 'Our team usually takes 24-48 hours to approve new services. Please wait or contact support for help.';

  @override
  String get contact_support => 'Contact Support';

  @override
  String get request_denied => 'Request Denied';

  @override
  String service_request_rejected(Object service) {
    return 'Your request for $service has been rejected.';
  }

  @override
  String get service_rejected_help => 'This might be due to missing information or eligibility. Please reach out to our team to appeal.';

  @override
  String get appeal_decision => 'Appeal Decision';

  @override
  String get access_limited => 'Access Limited';

  @override
  String service_suspended_or_cancelled(Object service) {
    return 'Your $service service is currently suspended or cancelled.';
  }

  @override
  String get service_accounts_help => 'Please check your subscription status or contact our customer team to resolve this issue.';

  @override
  String get contact_accounts => 'Contact Accounts';

  @override
  String get service_maintenance => 'Service Maintenance';

  @override
  String service_being_updated(Object service) {
    return '$service is currently being updated.';
  }

  @override
  String get service_maintenance_help => 'We are adding new features to improve your experience. Check back shortly!';

  @override
  String get back_to_dashboard => 'Back to Dashboard';

  @override
  String get maybe_later => 'Maybe Later';

  @override
  String get email_support => 'Email Support';

  @override
  String get chat_on_whatsapp => 'Chat on WhatsApp';

  @override
  String get systems => 'Systems';

  @override
  String get delivery => 'Delivery';

  @override
  String get company_profile => 'Company Profile';

  @override
  String get subscription => 'Subscription';

  @override
  String get switch_to_user_view => 'Switch to User View';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get notifications => 'Notifications';

  @override
  String get app_preferences => 'App Preferences';

  @override
  String get push_notifications => 'Push Notifications';

  @override
  String get localization => 'Localization';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get startup_roles => 'Startup & Roles';

  @override
  String get startup_role_subtitle => 'Automatically open your preferred dashboard when the app starts';

  @override
  String get edit_company => 'Edit Company';

  @override
  String get profile_updated_success => 'Profile updated successfully!';

  @override
  String get subscription_required => 'Subscription Required';

  @override
  String get subscription_required_msg => 'You need an active subscription to access this feature.';

  @override
  String get view_plans => 'View Plans';

  @override
  String get no_products_in_stock => 'No products in stock';

  @override
  String get search => 'Search';

  @override
  String get system_parameters => 'System Parameters';

  @override
  String appliances_count_label(Object count) {
    return '$count appliances';
  }

  @override
  String total_load_watts_label(Object watts) {
    return '$watts W total load';
  }

  @override
  String get total_pv_power => 'Total PV Power';

  @override
  String get total_battery => 'Total Battery';

  @override
  String get charge_controller => 'Charge Controller';

  @override
  String get peak_sun_hours => 'Peak Sun Hours';

  @override
  String get autonomy => 'Autonomy';

  @override
  String get request_notes_hint => 'Specific installation constraints, location notes, or other requests...';

  @override
  String get new_system => 'New System';

  @override
  String get select_system => 'Select System';

  @override
  String get add_calculation_to_existing_system => 'Add calculation to existing system:';

  @override
  String get no_saved_systems_found => 'No saved systems found.';

  @override
  String get system_name => 'System Name';

  @override
  String get system_name_hint => 'e.g., My Dream Home';

  @override
  String get select_installer_optional => 'Select Installer (Optional):';

  @override
  String get search_company_hint => 'Search company...';

  @override
  String get confirm_request_details => 'Confirm request details';

  @override
  String get add_notes_constraints => 'Add any notes or specific constraints...';

  @override
  String get low_voltage => 'Low Voltage';

  @override
  String get high_voltage => 'High Voltage';

  @override
  String get single_phase => 'Single Phase';

  @override
  String get hybrid => 'Hybrid';

  @override
  String get on_grid => 'On-Grid';

  @override
  String get off_grid => 'Off-Grid';

  @override
  String get lithium => 'Lithium';

  @override
  String get gel_lead_acid_tubular => 'Gel / Lead-Acid / Tubular';

  @override
  String get panel_calc_intro => 'Calculate the number of solar panels required based on your daily energy usage.';

  @override
  String get total_daily_usage => 'Total Daily Usage';

  @override
  String get system_efficiency_loss_factor => 'System Efficiency / Loss Factor';

  @override
  String get required_panels => 'Required Panels';

  @override
  String total_array_kw(Object value) {
    return 'Total Array: $value kW';
  }

  @override
  String get did_you_know => 'Did you know?';

  @override
  String get panel_calc_tip_text => '• Ah (amp-hours) = watts ÷ voltage.\n• Example: a 1000 Wh daily load on a 12 V system equals about 83.3 Ah.\n• We include efficiency losses so the system still performs well in real conditions.';

  @override
  String get inverter_calc_intro => 'Size your inverter to handle peak loads safely.';

  @override
  String get total_load_amps => 'Total Load Amps';

  @override
  String get amps => 'Amps';

  @override
  String get ac_system_voltage => 'AC System Voltage';

  @override
  String get safety_factor_oversizing => 'Safety Factor (Over-sizing)';

  @override
  String get recommended_inverter_size => 'Recommended Inverter Size';

  @override
  String approx_watts(Object value) {
    return '(Approx. $value Watts)';
  }

  @override
  String get inverter_calc_tip_text => '• Inverters are usually sized 20% to 30% above the continuous load.\n• The safety factor helps cover startup surges from motors such as refrigerators or pumps.';

  @override
  String get wires_calc_intro => 'Select the application type to get a recommended wire size.';

  @override
  String get application_type => 'Application Type';

  @override
  String get dc_solar => 'DC Solar';

  @override
  String get dc_battery => 'DC Battery';

  @override
  String get ac_single_phase => 'AC Single Phase';

  @override
  String get ac_three_phase => 'AC Three Phase';

  @override
  String get volts => 'Volts';

  @override
  String get current => 'Current';

  @override
  String get distance_one_way => 'Distance (One Way)';

  @override
  String get metres => 'Metres';

  @override
  String get allowable_voltage_drop => 'Allowable Voltage Drop';

  @override
  String get recommended_wire_size => 'Recommended Wire Size';

  @override
  String get wires_calc_tip_text => '• Keeping voltage drop low is critical for system efficiency.\n• For battery cables, aim for less than 1% drop to avoid inverter cut-offs.\n• For solar PV runs, 3% is generally acceptable.';

  @override
  String get pump_calc_intro => 'Calculate the solar power needed for your water pump system.';

  @override
  String get daily_water_volume => 'Daily Water Volume';

  @override
  String get total_dynamic_head => 'Total Dynamic Head (TDH)';

  @override
  String get pumping_hours => 'Pumping Hours';

  @override
  String get location_peak_sun_hours => 'Location Peak Sun Hours (PSH)';

  @override
  String get solar_panel_wattage => 'Solar Panel Wattage';

  @override
  String get pump_efficiency => 'Pump Efficiency';

  @override
  String get required_solar_panels => 'Required Solar Panels';

  @override
  String get hydraulic_power_est => 'Hydraulic Power Estimate';

  @override
  String motor_hp_estimate(Object value) {
    return '(~$value HP) Motor';
  }

  @override
  String get definitions => 'Definitions';

  @override
  String get flow_rate => 'Flow Rate';

  @override
  String get hydraulic_power => 'Hydraulic Power';

  @override
  String get definition_tdh => 'Vertical lift + friction losses + required pressure.';

  @override
  String get definition_flow_rate => 'The amount of water needed each day, for example in cubic meters.';

  @override
  String get definition_psh => 'Equivalent hours of full solar intensity at your location, usually around 4 to 6 hours.';

  @override
  String get definition_hydraulic_power => 'The power required to lift the water before motor efficiency losses are applied.';

  @override
  String get find_battery_count => 'Find Battery Count';

  @override
  String get find_backup_time => 'Find Backup Time';

  @override
  String get how_many_batteries_need => 'How many batteries do you need?';

  @override
  String get how_long_batteries_last => 'How long will your batteries last?';

  @override
  String get required_backup_time => 'Required Backup Time';

  @override
  String get hours => 'Hours';

  @override
  String get required_batteries => 'Required Batteries';

  @override
  String batteries_count_value(Object count) {
    return '$count Batteries';
  }

  @override
  String battery_for_spec(Object capacity, Object voltage) {
    return 'For ${capacity}Ah @ ${voltage}V';
  }

  @override
  String get estimated_runtime => 'Estimated Runtime';

  @override
  String runtime_hours_value(Object value) {
    return '$value Hours';
  }

  @override
  String get number_of_batteries => 'Number of Batteries';

  @override
  String get battery_capacity_ah => 'Battery Capacity (Ah)';

  @override
  String get depth_of_discharge_dod => 'Depth of Discharge (DoD)';

  @override
  String get typical_dod_hint => 'Typical: 50% for Gel/AGM, 80% for Lithium, 20-30% for Lead-Acid';

  @override
  String get battery_count_formula_hint => 'Formula: (Load × Time) ÷ (Battery Voltage × Capacity × DoD)';

  @override
  String get battery_runtime_formula_hint => 'Calculates how long the battery bank can sustain the load before reaching the selected depth of discharge.';

  @override
  String get battery_calculator_title => 'Battery Calculator';

  @override
  String get time_calculate => 'Time Calculate';

  @override
  String get count_calculate => 'Count Calculate';

  @override
  String get your_load_ampere => 'Your Load Ampere';

  @override
  String get example_10 => 'e.g., 10';

  @override
  String get numbers_only => 'Numbers only';

  @override
  String get load_ampere_helper => 'Enter the load in amperes and select the AC system voltage. Load is usually calculated as voltage × current. Example: 10 A × 230 V = 2300 W.';

  @override
  String get battery_amperes => 'Battery Capacity';

  @override
  String get battery_voltage_label => 'Battery Voltage';

  @override
  String get battery_count_label => 'Battery Count';

  @override
  String get battery_count_hint => 'One or more';

  @override
  String get runtime_question => 'How many hours do you need the system to run on batteries?';

  @override
  String get required_runtime_hours => 'Required Runtime (hours)';

  @override
  String get example_100_or_200 => 'e.g., 100 or 200';

  @override
  String get example_12_24_48_512 => 'e.g., 12, 24, 48, or 51.2';

  @override
  String get example_5_or_8 => 'e.g., 5 or 8';

  @override
  String get battery_count_explanation => 'The number of batteries needed is calculated as:\n\n(Power × Time) ÷ (Battery Voltage × Capacity × DoD)\n\nExample: (2300 W × 5 h) ÷ (12 V × 100 Ah × 0.2) = about 8 batteries.\n\nThis helps estimate how many batteries are needed for a specific load and runtime.';

  @override
  String depth_of_discharge_with_value(Object value) {
    return 'Battery Depth of Discharge ($value%)';
  }

  @override
  String get dod_guidance => 'Set the depth of discharge (DoD).\n\nTypical values range from 20% to 80% depending on battery type.\n\n• 20% for Lithium or Tubular\n• 50% for AGM or Gel\nCheck the battery datasheet for the best accuracy.';

  @override
  String get battery_runtime_explanation => 'Enter the battery capacity (Ah), voltage (V), and number of batteries.\nThe total stored energy is calculated as:\nVoltage × Capacity × Number of Batteries × Depth of Discharge.\n\n• Example: 4 batteries × 12 V × 100 Ah × 0.2 = 960 Wh\nThis helps estimate how long the battery system can power your load.';

  @override
  String get dod_guidance_runtime => 'Set the battery depth of discharge (DoD).\n\nTypical values usually range between 50% and 80% depending on battery type, temperature, and manufacturer guidance.\n\n• Use 20% for Lithium or Tubular batteries.\n• Use 50% for AGM or Gel batteries.\nRefer to the datasheet if you are unsure.';

  @override
  String runtime_hours_precise(Object value) {
    return '$value hours';
  }

  @override
  String get save_to_system => 'Save to System';
}
